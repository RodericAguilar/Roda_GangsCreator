ESX = exports['es_extended']:getSharedObject()
local gangPoints = {}

AddEventHandler('onResourceStart', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then
        return
    end
    Wait(100)
    TriggerClientEvent('chat:addSuggestion', -1, '/setgang', 'Para ponerle la banda a un jugador', {
        { name = 'playerId', help = 'ID del jugador' },
        { name = 'gangName', help = 'Nombre de la banda' },
        { name = 'gangRank', help = 'Rango de la banda' }
    })
    print('^3[Roda_GangsCreator]^0 - ^2Suggestions started.^0')
    Wait(100)
    local result = GetAllGangs()

    for i = 1, #result, 1 do
        if result[i].points ~= nil then
            local decode = json.decode(result[i].points)
            Wait(500)
            table.insert(gangPoints, {gang = result[i].name, ganglabel = result[i].label, clothes = decode['clothes'], inventory = decode['inventario'], vehicle = decode['vehicle'], bossmenu = decode['boss']})

            if Config.Inventory == 'ox_inventory' then
                exports.ox_inventory:RegisterStash(result[i].name.. '-stash', 'Inventory - ' ..result[i].label, 50, 100000, false)
            end
        else
            print('^3[Roda_GangsCreator]^0 - ^1Gang ^2' .. result[i].name .. '^1 has no points.')
        end
    end

    print('^3[Roda_GangsCreator]^0 - ^2Gangs getter.^0')
end)

RegisterServerEvent('Roda_GangsCreator:GetAllGangs')
AddEventHandler('Roda_GangsCreator:GetAllGangs', function()
    local src = source
    local access = CheckAccess(src)

    if access then
        local gangs = GetAllGangs()
        TriggerClientEvent('Roda_GangsCreator:SendAllGangs', src, gangs)
    else
        DropPlayer(src, 'Cheating detected')
    end
end)

RegisterServerEvent('Roda_GangsCreator:saveGang')
AddEventHandler('Roda_GangsCreator:saveGang', function (datos, actions)
    local src = source
    local access = CheckAccess(src)

    if access then
        SaveGang(src, datos, actions)
    else
        DropPlayer(src, 'Cheating detected')
    end
end)

RegisterServerEvent('Roda_GangsCreator:getUserGang')
AddEventHandler('Roda_GangsCreator:getUserGang', function()
    local src = source
    local data = GetGang(src)
    local gangInfo = GetGangInfo(data.gang)
    local acciones = json.decode(gangInfo.acciones)
    local gangLabel = gangInfo.ganglabel
    TriggerClientEvent('Roda_GangsCreator:userGang', src, data, acciones, gangLabel)
end)

RegisterCommand('gangs', function(source)
    local src = source
    local access = CheckAccess(src)

    if access then
        OpenUI(src)
    else
        TriggerClientEvent('Roda_GangsCreator:client:sendNotification', src, Locales[Config.Language]['no_access'])
    end
end)

RegisterCommand('setgang', function(source, args)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    local access = CheckAccess(src)

    if access then
        local user = tonumber(args[1])
        local gang = args[2]
        local rank = tonumber(args[3])
        local valid = CheckValidGang(gang)

        if user then
            if GetPlayerName(user) then
                if gang then
                    if rank then
                        if rank <= 3 then
                            if valid then
                                SetGang(user, gang, rank)
                                TriggerClientEvent('Roda_GangsCreator:client:sendNotification', src, Locales[Config.Language]['asign_gang']:format(GetPlayerName(user), gang))
                                TriggerClientEvent('Roda_GangsCreator:Refresh', user)
                            else
                                TriggerClientEvent('Roda_GangsCreator:client:sendNotification', src, Locales[Config.Language]['invalid_gang']:format(gang))
                            end
                        else
                            TriggerClientEvent('Roda_GangsCreator:client:sendNotification', src, Locales[Config.Language]['invalid_rank'])
                        end
                    else
                        TriggerClientEvent('Roda_GangsCreator:client:sendNotification', src, Locales[Config.Language]['invalid_rank_specify'])
                    end
                else
                    TriggerClientEvent('Roda_GangsCreator:client:sendNotification', src, Locales[Config.Language]['invalid_gang_specify'])
                end
            else
                TriggerClientEvent('Roda_GangsCreator:client:sendNotification', src, Locales[Config.Language]['not_player_valid'])
            end
        else
            TriggerClientEvent('Roda_GangsCreator:client:sendNotification', src, Locales[Config.Language]['invalid_value'])
        end
    else
        TriggerClientEvent('Roda_GangsCreator:client:sendNotification', src, Locales[Config.Language]['not_perms'])
    end
end)

RegisterCommand('mygang', function(source)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    local userGang = GetGang(src)
    if userGang.gang ~= 'NULL' then
        local ganglabel = GetGangInfo(userGang.gang).ganglabel
        if ganglabel == 'NULL' then 
            TriggerClientEvent('Roda_GangsCreator:client:sendNotification', src, Locales[Config.Language]['no_gang'])
        else
        TriggerClientEvent('Roda_GangsCreator:client:sendNotification', src, Locales[Config.Language]['in_gang']:format(ganglabel))
        end
    else
        TriggerClientEvent('Roda_GangsCreator:client:sendNotification', src, Locales[Config.Language]['no_gang'])
    end
end)

RegisterCommand('reclutemember', function(source)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    local isBoss = CheckBoss(src)

    if isBoss then
        TriggerClientEvent('Roda_GangsCreator:SendBoss', src)
    else
        TriggerClientEvent('Roda_GangsCreator:client:sendNotification', src, Locales[Config.Language]['not_perms'])
    end
end)

RegisterServerEvent('Roda_GangsCreator:server:handcuff')
AddEventHandler('Roda_GangsCreator:server:handcuff', function(target)
    TriggerClientEvent('Roda_GangsCreator:client:handcuff', target)
end)

RegisterServerEvent('Roda_GangsCreator:server:drag')
AddEventHandler('Roda_GangsCreator:server:drag', function(target)
    TriggerClientEvent('Roda_GangsCreator:client:drag', target, source)
end)

RegisterServerEvent('Roda_GangsCreator:server:SavePoints')
AddEventHandler('Roda_GangsCreator:server:SavePoints', function (gang, clothes, inventario, garage, boss)
    local src = source
    local access = CheckAccess(src)

    if access then
        SavePoints(gang, clothes, inventario, garage, boss)
        Wait(500)
        TriggerEvent('Roda_GangsCreator:server:UpdatePoints')
        Wait(250)
        TriggerClientEvent('Roda_GangsCreator:client:getGangs', -1)
    else
        DropPlayer(src, 'Cheating detected')
    end
end)

RegisterServerEvent('Roda_GangsCreator:server:UpdatePoints')
AddEventHandler('Roda_GangsCreator:server:UpdatePoints', function()
    local result = GetAllGangs()
    gangPoints = {}

    for i = 1, #result, 1 do
        local decode = json.decode(result[i].points)
        Wait(5)
        table.insert(gangPoints, {gang = result[i].name, ganglabel = result[i].label, clothes = decode['clothes'], inventory = decode['inventario'], vehicle = decode['vehicle'], bossmenu = decode['boss']})

        if Config.Inventory == 'ox_inventory' then
            exports.ox_inventory:RegisterStash(result[i].name.. '-stash', 'Inventory - ' ..result[i].label, 50, 100000, false)
        end
    end
    print('^3[Roda_GangsCreator]^0 - ^2 Actualizando puntos de bandas. ^0')
end)

RegisterServerEvent('Roda_GangsCreator:server:RequestMembers')
AddEventHandler('Roda_GangsCreator:server:RequestMembers', function(gang)
    local src = source
    local members = GetMembers(src, gang)

    if not members then
        TriggerClientEvent('Roda_GangsCreator:client:sendNotification', src, Locales[Config.Language]['not_members'])
    else
        TriggerClientEvent('Roda_GangsCreator:client:RequestMembers', src, members)
    end
end)

RegisterServerEvent('Roda_GangsCreator:server:RequestVehicles')
AddEventHandler('Roda_GangsCreator:server:RequestVehicles', function(gang)
    local src = source
    local vehicles = GetVehicles(gang)

    if not vehicles then
        TriggerClientEvent('Roda_GangsCreator:client:sendNotification', src, Locales[Config.Language]['not_vehicles'])
    else
        TriggerClientEvent('Roda_GangsCreator:client:RequestVehicles', src, json.decode(vehicles))
    end
end)

RegisterServerEvent('Roda_GangsCreator:server:RequestClothes')
AddEventHandler('Roda_GangsCreator:server:RequestClothes', function(sex, gang)
    local src = source
    local sexo = sex
    if sexo == 'male' then
        local maleClothes = GetSkinsM(gang)
        if not maleClothes then
            TriggerClientEvent('Roda_GangsCreator:client:sendNotification', src, Locales[Config.Language]['not_clothes'])
        else
            TriggerClientEvent('Roda_GangsCreator:client:RequestClothes', src, json.decode(maleClothes))
        end
    else
        local femaleClothes = GetSkinsF(gang)
        if not femaleClothes then
            TriggerClientEvent('Roda_GangsCreator:client:sendNotification', src, Locales[Config.Language]['not_clothes'])
        else
            TriggerClientEvent('Roda_GangsCreator:client:RequestClothes', src, json.decode(femaleClothes))
        end
    end
end)

ESX.RegisterServerCallback('Roda_GangsCreator:server:GetPoints', function(source, cb)
    local xPlayer = ESX.GetPlayerFromId(source)

    while xPlayer == nil do
        xPlayer = ESX.GetPlayerFromId(source)
        Wait(500)
    end

    local userGang = GetGang(source)
    local puntos = {}

    for i = 1, #gangPoints, 1 do
        if gangPoints[i].gang == userGang.gang then
            table.insert(puntos, {gang = gangPoints[i].gang, clothes = gangPoints[i].clothes, inventory = gangPoints[i].inventory, vehicle = gangPoints[i].vehicle, bossmenu = gangPoints[i].bossmenu})
        end
    end

    Wait(500)
    cb(puntos)
end)

ESX.RegisterServerCallback('Roda_GangsCreator:getPlayerOutfit', function(source, cb, num)
    local xPlayer = ESX.GetPlayerFromId(source)

    TriggerEvent('esx_datastore:getDataStore', 'housing', xPlayer.identifier, function(store)
        local outfit = store.get('dressing', num)
        cb(outfit.skin)
    end)
end)

RegisterServerEvent('Roda_GangsCreator:server:SetNewRange')
AddEventHandler('Roda_GangsCreator:server:SetNewRange', function (identifier, rango)
    UpdateUserRange(identifier, rango)
end)


RegisterServerEvent('Roda_GangsCreator:server:AddNewCar')
AddEventHandler('Roda_GangsCreator:server:AddNewCar', function(gang, vehiclename, vehiclelabel)
    local src = source
    local access = CheckAccess(src)

    if access then
        AddVehicle(gang, vehiclename, vehiclelabel)
    else
        DropPlayer(src, 'Cheating detected')
    end
end)

RegisterServerEvent('Roda_GangsCreator:server:SaveOutfit')
AddEventHandler('Roda_GangsCreator:server:SaveOutfit', function (sexo, labeloutfit, skin, gang)
    local src = source
    local access = CheckAccess(src)

    if access then
        if sexo == 'male' then 
            SaveOutfit(sexo, labeloutfit, skin, gang)
        else
            SaveOutfitF(sexo, labeloutfit, skin, gang)
        end
    else
        DropPlayer(src, 'Cheating detected')
    end
end)

RegisterServerEvent('Roda_GangsCreator:server:RequestClothesForPlayer')
AddEventHandler('Roda_GangsCreator:server:RequestClothesForPlayer', function (name, gang, sexo)
    local src = source
    local skin = GetSkinFromName(name, gang)
    local skinf = GetSkinFromNameF(name, gang)
    if sexo == 'male' then
        if not skin then
            TriggerClientEvent('Roda_GangsCreator:client:sendNotification', src, Locales[Config.Language]['not_clothes'])
        else
            TriggerClientEvent('Roda_GangsCreator:client:RequestClothesForPlayer', src, skin)
        end
    else
        if not skinf then
            TriggerClientEvent('Roda_GangsCreator:client:sendNotification', src, Locales[Config.Language]['not_clothes'])
        else
            TriggerClientEvent('Roda_GangsCreator:client:RequestClothesForPlayer', src, skinf)
        end
    end
end)

RegisterServerEvent('Roda_GangsCreator:server:AddNewMember')
AddEventHandler('Roda_GangsCreator:server:AddNewMember', function (pid, name, range, gang)
    local src = source
    local access = CheckBoss(src)
    local valid = GetPlayerName(pid)
    local gangInfo = GetGangInfo(gang)
    local label = gangInfo.ganglabel
    if access then
        if valid ~= nil then 
           -- SetGang(pid, gang, range)
           -- TriggerClientEvent('Roda_GangsCreator:Refresh', pid)
           TriggerClientEvent('Roda_GangsCreator:client:sendInvitation', pid, src, pid, gang, range, label)
        else
            TriggerClientEvent('Roda_GangsCreator:client:sendNotification', src, Locales[Config.Language]['not_player_valid'])
        end
    else
        DropPlayer(src, 'Cheating detected')
    end
end)

RegisterServerEvent('Roda_GangsCreator:server:AcceptNewMember')
AddEventHandler('Roda_GangsCreator:server:AcceptNewMember', function (jefe, target, gang, range)
    local valid = GetPlayerName(jefe)
    if valid then 
        SetGang(target, gang, range)
        TriggerClientEvent('Roda_GangsCreator:Refresh', target)
        TriggerClientEvent('Roda_GangsCreator:client:sendNotification', jefe,  Locales[Config.Language]['accept_gang']:format(GetPlayerName(target), GetGangInfo(gang).ganglabel))
    else
        SetGang(target, gang, range)
        TriggerClientEvent('Roda_GangsCreator:Refresh', target)
    end
end)

RegisterServerEvent('Roda_GangsCreator:server:DeniedNewMember')
AddEventHandler('Roda_GangsCreator:server:DeniedNewMember', function (jefe, target, gang, range)
    local valid = GetPlayerName(jefe)
    if valid then 
        TriggerClientEvent('Roda_GangsCreator:client:sendNotification', jefe,  Locales[Config.Language]['denied_gang']:format(GetPlayerName(target), GetGangInfo(gang).ganglabel))
        TriggerClientEvent('Roda_GangsCreator:client:sendNotification', target,  Locales[Config.Language]['denied_gang_target']:format(GetGangInfo(gang).ganglabel)) 
    else
        TriggerClientEvent('Roda_GangsCreator:client:sendNotification', target,  Locales[Config.Language]['denied_gang_target']:format(GetGangInfo(gang).ganglabel)) 
    end
end)

RegisterServerEvent('Roda_GangsCreator:client:DeleteNewRange')
AddEventHandler('Roda_GangsCreator:client:DeleteNewRange', function (identifier)
    local src = source 
    local connect = CheckConnectedMember(identifier)
    if not connect then 
        FireMember(identifier)
    else
        FireMemberOn(connect)
    end
end)


RegisterServerEvent('Roda_GangsCreator:server:GetIdentity')
AddEventHandler('Roda_GangsCreator:server:GetIdentity', function (target)
    local src = source 
    local data = GetDataForTheIdentity(target)
    TriggerClientEvent('Roda_GangsCreator:client:GetIdentity', src, target, data)
end)
