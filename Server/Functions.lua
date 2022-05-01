--Return the call to database
--@param plugin string
--@param type string
--@param query string
--@param var string
function Query(plugin, type, query, var)
	local wait = promise.new()
    if type == 'fetchAll' and plugin == 'mysql' then
		MySQL.Async.fetchAll(query, var, function(result)
            wait:resolve(result)
        end)
    end
    if type == 'execute' and plugin == 'mysql' then
        MySQL.Async.execute(query, var, function(result)
            wait:resolve(result)
        end)
    end
    if type == 'execute' and plugin == 'ghmattisql' then
        exports['ghmattimysql']:execute(query, var, function(result)
            wait:resolve(result)
        end)
    end
    if type == 'fetchAll' and plugin == 'ghmattisql' then
        exports.ghmattimysql:execute(query, var, function(result)
            wait:resolve(result)
        end)
    end
    if type == 'execute' and plugin == 'oxmysql' then
        exports.oxmysql:execute(query, var, function(result)
            wait:resolve(result)
        end)
    end
    if type == 'fetchAll' and plugin == 'oxmysql' then
		exports['oxmysql']:fetch(query, var, function(result)
			wait:resolve(result)
		end)
    end
	return Citizen.Await(wait)
end

--Return boolean if player this admin
--@param src number
--@return boolean
function CheckAccess(src)
    local src = src
    local xPlayer = ESX.GetPlayerFromId(src)
    local group = xPlayer.getGroup()

    for k,v in pairs(Config.Admins) do
        if v == group then 
            return true
        end
    end
    return false
end

function OpenUI(src)
    local src = src
    local xPlayer = ESX.GetPlayerFromId(src)
    local access = CheckAccess(src)
    if access then 
        TriggerClientEvent('Roda_GangsCreator:openUI', src)
    else
        TriggerClientEvent('Roda_GangsCreator:client:sendNotification', src, Locales[Config.Language]['not_perms'])
    end
end

function GetAllGangs()
    local result = Query(Config.Db, 'fetchAll', "SELECT * FROM roda_gangs")
    return result
end

function GetGangInfo(gang)
    local result = Query(Config.Db, 'fetchAll', "SELECT * FROM roda_gangs WHERE name = @id", {['@id'] = gang})
    if result[1] == nil then 
        return {
            acciones = 'NULL',
            ganglabel = 'NULL',
        }
    else
        return {
            acciones = result[1].acciones,
            ganglabel = result[1].label,
        }
    end
end

function GetGang(src)
    local src = src

    while not ESX.GetPlayerFromId(src) do
        Wait(100)
    end

    local xPlayer = ESX.GetPlayerFromId(src)
    local identifier = xPlayer.identifier
    local result = Query(Config.Db, 'fetchAll', "SELECT gang, gang_grade FROM users WHERE identifier = @name", {['@name'] = identifier})
    if json.encode(result[1]) == '[]' or nil then
        TriggerClientEvent('Roda_GangsCreator:client:sendNotification', src, Locales[Config.Language]['not_in_gang'])
        return {
            gang = 'NULL',
            grade = 'NULL'
        }
    else
       return {
            gang = result[1].gang,
            grade = result[1].gang_grade
       }
    end
end

--@param src number
--@param data table
--@param actions table
function SaveGang(src, data, actions)
    local datos = data 
    local name = datos.name
    local label = datos.label
    local logo = datos.logo
    local color = datos.color
    local acciones = json.encode(actions)
    local result = Query(Config.Db, 'fetchAll',
    "SELECT * FROM roda_gangs WHERE name = @name", {['@name'] = name})
    local xPlayer = ESX.GetPlayerFromId(src)
    if result[1] ~= nil then
        TriggerClientEvent('Roda_GangsCreator:client:sendNotification', src, Locales[Config.Language]['gang_exists'])
    else
        Query(Config.Db, 'execute',"INSERT INTO roda_gangs (`name`, `label`, `logo`, `color`, `acciones`) VALUES (@name, @label, @logo, @color, @acciones)", {
            ['@name'] = name,
            ['@label'] = label,
            ['@logo'] = logo,
            ['@color'] = color,
            ['@acciones'] = acciones
        })
        TriggerClientEvent('Roda_GangsCreator:client:sendNotification', src, Locales[Config.Language]['gang_created'])
    end
end

function CheckValidGang(gang)
    local result = Query(Config.Db, 'fetchAll', 'SELECT * FROM roda_gangs WHERE name = @name', {['@name'] = gang})

    if result[1] ~= nil then
        return true
    else
        return false
    end
end

function SetGang(src, gang, rank)
    local valid = CheckValidGang(gang)
    local xPlayer = ESX.GetPlayerFromId(src)
    local identifier = xPlayer.identifier

    if valid then
        Query(Config.Db, 'execute', "UPDATE users SET gang = @gang, gang_grade = @rank WHERE identifier = @identifier", {
            ['@gang'] = gang,
            ['@rank'] = rank,
            ['@identifier'] = identifier
        })
        TriggerClientEvent('Roda_GangsCreator:client:sendNotification', src, Locales[Config.Language]['added_to_gang']:format(GetGangInfo(gang).ganglabel))
        TriggerClientEvent('Roda_GangsCreator:client:getGangs', src)
    else
        TriggerClientEvent('Roda_GangsCreator:client:sendNotification', src, Locales[Config.Language]['gang_not_exists'])
    end
end

function GetPoints(gang)
    local result = Query(Config.Db, 'fetchAll', 'SELECT * FROM roda_gangs WHERE name = @name', {['@name'] = gang})

    return result[1].points or {}
end

function SavePoints(gang, clothes, inventario, vehicle, boss)
    local result = Query(Config.Db, 'fetchAll', 'SELECT * FROM roda_gangs WHERE name = @name', {['@name'] = gang})

    local puntitos = {}
    puntitos = {clothes = clothes, inventario = inventario, vehicle = vehicle, boss = boss}
    Query(Config.Db, 'execute', 'UPDATE roda_gangs SET points = @points WHERE name = @name', {
        ['@points'] = json.encode(puntitos),
        ['@name'] = gang
    })
    print('[^2Roda_GangsCreator^0] Guardado puntos de ^3' ..gang.. '^0.')
end

function GetMembers(src, gang)
    local result = Query(Config.Db, 'fetchAll', 'SELECT * FROM users WHERE gang = @gang and gang_grade != 3', {['@gang'] = gang})
    if json.encode(result) ~= '[]' then
        return result
    else
        return false
    end
end

function GetVehicles(gang)
    local result = Query(Config.Db, 'fetchAll', 'SELECT * FROM roda_gangs WHERE name = @gang', {['@gang'] = gang})

    if json.encode(result[1].vehicles) ~= '""' then
        return result[1].vehicles
    else
        return false
    end
end

function GetSkinsM(gang)
    local result = Query(Config.Db, 'fetchAll', 'SELECT * FROM roda_gangs WHERE name = @gang', {['@gang'] = gang})

    if json.encode(result[1].m_outfit) ~= '""' then
        return(result[1].m_outfit)
    else
        return false
    end
end

function GetSkinsF(gang) 
    local result = Query(Config.Db, 'fetchAll', 'SELECT * FROM roda_gangs WHERE name = @gang', {['@gang'] = gang})

    if json.encode(result[1].f_outfit) ~= '""' then
        return(result[1].f_outfit)
    else
        return false
    end
end

function UpdateUserRange(identifier, rango)
    Query(Config.Db, 'execute', 'UPDATE users SET gang_grade = @rango WHERE identifier = @identifier', {
        ['@rango'] = rango,
        ['@identifier'] = identifier
    })
end

function AddVehicle(gang, vehiclename, vehiclelabel)
    local result = Query(Config.Db, 'fetchAll', 'SELECT * FROM roda_gangs WHERE name = @gang', {['@gang'] = gang})
    local vehicles = json.decode(result[1].vehicles)

    if vehicles == nil then
        local newvehicles = {}
        table.insert(newvehicles, {name = vehiclename, label = vehiclelabel})
        Query(Config.Db, 'execute', 'UPDATE roda_gangs SET vehicles = @vehicles WHERE name = @gang', {
            ['@vehicles'] = json.encode(newvehicles),
            ['@gang'] = gang
        })
    else
        table.insert(vehicles, {name = vehiclename, label = vehiclelabel})
        Query(Config.Db, 'execute', 'UPDATE roda_gangs SET vehicles = @vehicles WHERE name = @gang', {
            ['@vehicles'] = json.encode(vehicles),
            ['@gang'] = gang
        })
    end
end

function SaveOutfit(sexo, label, skin, gang)
    local result = Query(Config.Db, 'fetchAll', 'SELECT * FROM roda_gangs WHERE name = @gang', {['@gang'] = gang})
    local m_outfit = json.decode(result[1].m_outfit)
    local name = label:gsub("%s+", "")
    if m_outfit == nil then 
        local newOutfits = {}
        table.insert(newOutfits, {label = label, skin = skin, name = name})
        Query(Config.Db, 'execute', 'UPDATE roda_gangs SET m_outfit = @outfit WHERE name = @gang ', {
            ['@outfit'] = json.encode(newOutfits),
            ['@gang'] = gang
        })
    else
        table.insert(m_outfit, {label = label, skin = skin, name = name})
        Query(Config.Db, 'execute', 'UPDATE roda_gangs SET m_outfit = @outfit WHERE name = @gang ', {
            ['@outfit'] = json.encode(m_outfit),
            ['@gang'] = gang
        })
    end
end

function SaveOutfitF(sexo, label, skin, gang)
    local result = Query(Config.Db, 'fetchAll', 'SELECT * FROM roda_gangs WHERE name = @gang', {['@gang'] = gang})
    local f_outfit = json.decode(result[1].f_outfit)
    local name = label:gsub("%s+", "")
    if f_outfit == nil then 
        local newOutfits = {}
        table.insert(newOutfits, {label = label, skin = skin, name = name})
        Query(Config.Db, 'execute', 'UPDATE roda_gangs SET f_outfit = @outfit WHERE name = @gang ', {
            ['@outfit'] = json.encode(newOutfits),
            ['@gang'] = gang
        })
    else
        table.insert(f_outfit, {label = label, skin = skin, name = name})
        Query(Config.Db, 'execute', 'UPDATE roda_gangs SET f_outfit = @outfit WHERE name = @gang ', {
            ['@outfit'] = json.encode(f_outfit),
            ['@gang'] = gang
        })
    end
end

function GetSkinFromName(name,gang)
    local result = Query(Config.Db, 'fetchAll', 'SELECT * FROM roda_gangs WHERE name = @gang', {['@gang'] = gang})
    local m_outfit = json.decode(result[1].m_outfit)
    local skin = nil
    if m_outfit ~= nil then
        for i, v in pairs(m_outfit) do
            if v.name == name then
                skin = v.skin
                return skin
            end
        end
    end
    return false
end

function GetSkinFromNameF(name,gang)
    local result = Query(Config.Db, 'fetchAll', 'SELECT * FROM roda_gangs WHERE name = @gang', {['@gang'] = gang})
    local f_outfit = json.decode(result[1].f_outfit)
    local skin = nil
    if f_outfit ~= nil then
        for i, v in pairs(f_outfit) do
            if v.name == name then
                skin = v.skin
                return skin
            end
        end
    end
    return false
end

function CheckBoss(src)
    local xPlayer = ESX.GetPlayerFromId(src)
    local identifier = xPlayer.identifier
    local result = Query(Config.Db, 'fetchAll', 'SELECT * FROM users WHERE identifier = @identifier', {['@identifier'] = identifier})

    if result[1].gang_grade == 3 then
        return true
    else
        return false
    end
end

function FireMember(identifier)
    Query(Config.Db, 'execute', 'UPDATE users SET gang_grade = 0, gang = Null WHERE identifier = @identifier', {
        ['@identifier'] = identifier
    })
end

function FireMemberOn(src) 
    local xPlayer = ESX.GetPlayerFromId(src)
    local identifier = xPlayer.identifier
    Query(Config.Db, 'execute', 'UPDATE users SET gang_grade = 0, gang = Null WHERE identifier = @identifier', {
        ['@identifier'] = identifier
    })
    TriggerClientEvent('Roda_GangsCreator:client:getGangs', src)
    TriggerClientEvent('Roda_GangsCreator:Refresh', src)
end


function CheckConnectedMember(identifier)
    local xAll = ESX.GetPlayers()
    local xTarget = nil
    for i=1, #xAll, 1 do
        xTarget = ESX.GetPlayerFromId(xAll[i])
        if xTarget.identifier == identifier then
            return xTarget.source
        end
    end
    return false
end

function GetDataForTheIdentity(src)
    local src = src 
    local xPlayer = ESX.GetPlayerFromId(src)
    local identifier = xPlayer.identifier
    local result = Query(Config.Db, 'fetchAll', 'SELECT * FROM users WHERE identifier = @identifier', {['@identifier'] = identifier})
    local data = {
        firstname = result[1].firstname,
        lastname = result[1].lastname,
        sex = result[1].sex
    }
    return data
end


-- Little pene---