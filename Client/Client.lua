ESX = exports['es_extended']:getSharedObject()
idioma = Config.Language
gang = nil
gang_grade = nil
gangLabel = nil
gang_points = {}
local loaded = false

local function DrawTxt(coords, text, size, font)
    local coords = vector3(coords.x, coords.y, coords.z)

    local camCoords = GetGameplayCamCoords()
    local distance = #(coords - camCoords)

    if not size then
        size = 1
    end

    if not font then
        font = 0
    end

    local scale = (size / distance) * 2
    local fov = (1 / GetGameplayCamFov()) * 100
    scale = scale * fov

    SetTextScale(0.0 * scale, 0.55 * scale)
    SetTextFont(font)
    SetTextColour(255, 255, 255, 215)
    SetTextDropshadow(0, 0, 0, 0, 255)
    SetTextEdge(2, 0, 0, 0, 150)
    SetTextDropShadow()
    SetTextOutline()
    SetTextEntry("STRING")
    SetTextCentre(true)

    SetDrawOrigin(coords, 0)
    BeginTextCommandDisplayText('STRING')
    AddTextComponentSubstringPlayerName(text)
    EndTextCommandDisplayText(0.0, 0.0)
    ClearDrawOrigin()
end

RegisterNetEvent('Roda_GangsCreator:userGang')
AddEventHandler('Roda_GangsCreator:userGang', function (data, acciones, label)
    if acciones ~= nil then
        gang = data.gang
        gang_grade = data.grade
        handcuff = acciones.esposar
        drag = acciones.drag
        search = acciones.search
        request = acciones.request
        gangLabel = label

        actionsPro = {
            handcuff = handcuff,
            drag = drag,
            search = search,
            request = request
        }
    else
        actionsPro = nil
    end
end)

RegisterNUICallback('requestGangs', function(data, cb)
    TriggerServerEvent('Roda_GangsCreator:GetAllGangs')
end)

RegisterNetEvent('Roda_GangsCreator:Refresh')
AddEventHandler('Roda_GangsCreator:Refresh', function()
    TriggerServerEvent('Roda_GangsCreator:getUserGang')
end)

RegisterNetEvent('Roda_GangsCreator:SendAllGangs')
AddEventHandler('Roda_GangsCreator:SendAllGangs', function(gangs)
    for k,v in pairs(gangs) do
        SendNUIMessage({
            action = 'showGang',
            gang = v.name,
            logo = v.logo,
            label = v.label
        })
    end
end)

CreateThread(function()
    while true do
        if NetworkIsSessionStarted() then
            TriggerServerEvent('Roda_GangsCreator:getUserGang')
            Wait(1000)
            if gangLabel == nil then
                print('No estas en ninguna banda.')
            else
                print('Estas en la banda: ' ..gangLabel)
            end
            Wait(100)
            TriggerEvent("Roda_GangsCreator:client:getGangs")
            loaded = true
            break
        end
        Wait(0)
    end
end)



RegisterNetEvent('Roda_GangsCreator:client:getGangs')
AddEventHandler('Roda_GangsCreator:client:getGangs', function()
    print('^3[Roda_GangsCreator]^0 - ^2Sincronizando puntos de bandas.^0')
    ESX.TriggerServerCallback('Roda_GangsCreator:server:GetPoints', function(points)
        gang_points = points
    end)
end)

RegisterKeyMapping('opengangmenu', 'Open Gang Menu', 'keyboard', 'F5')

RegisterCommand('opengangmenu', function()
    Wait(500)
    if not gangMenuOpen and actionsPro ~= nil then
        SetNuiFocus(true, true)
        SetNuiFocusKeepInput(true)
        SendNUIMessage({
            action = 'openGangMenu',
            actions = actionsPro,
            gang = gang,
            label = gangLabel
        })

        gangMenuOpen = true
        CreateThread(function()
            while gangMenuOpen do
                DisableDisplayControlActions()
                Wait(1)
            end
        end)
    elseif actionsPro == nil then
        Notification(Locales[idioma]['not_in_gang'], 'error')
    end
end)

RegisterNetEvent('Roda_GangsCreator:openUI')
AddEventHandler('Roda_GangsCreator:openUI', function ()
    SetNuiFocus(true, true)
    SendNUIMessage({
        action = "openUI"
    })
end)

RegisterNUICallback('exit', function(data, cb)
    SetNuiFocus(false, false)
    SetNuiFocusKeepInput(false)
    gangMenuOpen = false
end)

RegisterNUICallback('sendGang', function(data, cb)
    SetNuiFocus(false, false)
    local datos = {
        name = data.name,
        label = data.label,
        logo = data.logo,
        color = data.GangColor
    }

    local actions = {
        esposar = data.esposar,
        search = data.search,
        drag = data.drag,
        request = data.request
    }

    TriggerServerEvent('Roda_GangsCreator:saveGang', datos, actions)
end)

RegisterNUICallback('handcuff', function()
    local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()

    if closestPlayer ~= -1 and closestDistance <= 3.0 then
        TriggerServerEvent('Roda_GangsCreator:server:handcuff', GetPlayerServerId(closestPlayer))
    else
        Notification(Locales[idioma]['no_nearby'],'error')
    end
end)

RegisterNUICallback('drag', function()
    local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()
    
    if closestPlayer ~= -1 and closestDistance <= 3.0 then
        TriggerServerEvent('Roda_GangsCreator:server:drag', GetPlayerServerId(closestPlayer))
    else
        Notification(Locales[idioma]['no_nearby'],'error')
    end
end)

RegisterNUICallback('search', function()
    local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()
    
    if closestPlayer ~= -1 and closestDistance <= 3.0 then
        OpenSearchMenu(GetPlayerServerId(closestPlayer))
    else
        Notification(Locales[idioma]['no_nearby'],'error')
    end
end)

local pointsCoords = {}

RegisterNUICallback('makeClothes', function(data, cb)
    SetNuiFocus(false, false)
    vehiclecreated = true
    while true do
        Wait(0)

        if data.type == 'clothes' then
            hit, coords, entity = RayCastGamePlayCamera(1000.0)
            DrawMarker(1, coords - vector3(0, 0, 0.3), 0, 0, 0, 0, 0, 0, 2.0000, 2.0000, 0.6001,255,0,20, 255, 0, 0, 0, 0)

            ESX.ShowHelpNotification(Locales[idioma]['clothe_point'])
            if IsControlJustPressed(1, 38) then
                Wait(100)
                table.insert(pointsCoords, {clotheCoords = coords})
                SetNuiFocus(true, true)
                SendNUIMessage({
                    action = 'openCurrent'
                })
                break
            end
        end

        if data.type == 'deposit' then
            hit, coords, entity = RayCastGamePlayCamera(1000.0)
            DrawMarker(1, coords - vector3(0, 0, 0.3), 0, 0, 0, 0, 0, 0, 2.0000, 2.0000, 0.6001,255,0,20, 255, 0, 0, 0, 0)

            ESX.ShowHelpNotification(Locales[idioma]['inventory_point'])
            if IsControlJustPressed(1, 38) then
                Wait(100)
                table.insert(pointsCoords, {inventoryCoords = coords})
                SetNuiFocus(true, true)
                SendNUIMessage({
                    action = 'openCurrent'
                })
                break
            end
        end

        if data.type == 'vehicle' then
            local heading = GetEntityHeading(PlayerPedId())
            hit, coords, entity = RayCastGamePlayCamera(1000.0)
            DrawMarker(1, coords - vector3(0, 0, 0.3), 0, 0, 0, 0, 0, 0, 2.0000, 2.0000, 0.6001,255,0,20, 255, 0, 0, 0, 0)

            if vehiclecreated then
                local hash = GetHashKey("t20")
                RequestModel(hash)
                while not HasModelLoaded(hash) do
                    Wait(10)
                end
                veh = CreateVehicle(hash, coords, 100.00, false, false)
                SetEntityCollision(veh, false, false)
                vehiclecreated = false
            end

            SetEntityCoords(veh, coords)
            SetEntityHeading(veh, heading)           
            SetEntityAlpha(veh, 180, 0)
            ESX.ShowHelpNotification(Locales[idioma]['car_point'])

            if IsControlJustPressed(1, 38) then
                DeleteEntity(veh)
                Wait(100)
                table.insert(pointsCoords, {garageCoords = coords, garageHeading = heading})

                SetNuiFocus(true, true)
                SendNUIMessage({
                    action = 'openCurrent'
                })

                break
            end
        end

        if data.type == 'boss' then
            hit, coords, entity = RayCastGamePlayCamera(1000.0)
            DrawMarker(1, coords - vector3(0, 0, 0.3), 0, 0, 0, 0, 0, 0, 2.0000, 2.0000, 0.6001,255,0,20, 255, 0, 0, 0, 0)

            ESX.ShowHelpNotification(Locales[idioma]['boss_point'])
            if IsControlJustPressed(1, 38) then
                Wait(100)
                table.insert(pointsCoords, {bossCoords = coords})
                SetNuiFocus(true, true)
                SendNUIMessage({
                    action = 'openCurrent'
                })
                break
            end
        end
    end
end)

RegisterNUICallback('saveAllPoints', function(data, cb)
    TriggerServerEvent('Roda_GangsCreator:server:SavePoints', data.gangname, pointsCoords[1]['clotheCoords'], pointsCoords[2]['inventoryCoords'], pointsCoords[3]['garageCoords'], pointsCoords[4]['bossCoords'])
    SetNuiFocus(false, false)
end)

CreateThread(function()
    while true do
        local msec = 500
        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)

        if loaded then
            for k,v in pairs(gang_points) do
                if v.gang == gang then
                    if #(playerCoords - vector3(v.clothes.x, v.clothes.y, v.clothes.z)) < 1.5 then
                        msec = 0
                        DrawTxt(vector3(v.clothes.x, v.clothes.y, v.clothes.z + 1.0), Locales[idioma]['outfit_menu'], 0.7, 0)
                        if IsControlJustPressed(0, 38) then
                            OpenOutfits(gang)
                        end
                    elseif #(playerCoords - vector3(v.clothes.x, v.clothes.y, v.clothes.z)) < 5.0 then
                        msec = 0
                        DrawMarker(2, vector3(v.clothes.x, v.clothes.y, v.clothes.z + 1.0), 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.3, 0.3, -0.22, 220, 0, 0, 100, false, true, 2, true)
                    end

                    if #(playerCoords - vector3(v.inventory.x, v.inventory.y, v.inventory.z)) < 1.5 then
                        msec = 0
                        DrawTxt(vector3(v.inventory.x, v.inventory.y, v.inventory.z + 1.0), Locales[idioma]['inventory_menu'], 0.7, 0)
                        if IsControlJustPressed(0, 38) then
                            OpenStash(v.gang)
                        end
                    elseif #(playerCoords - vector3(v.inventory.x, v.inventory.y, v.inventory.z)) < 5.0 then
                        msec = 0
                        DrawMarker(2, vector3(v.inventory.x, v.inventory.y, v.inventory.z + 1.0), 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.3, 0.3, -0.22, 220, 0, 0, 100, false, true, 2, true)
                    end

                    if #(playerCoords - vector3(v.vehicle.x, v.vehicle.y, v.vehicle.z)) < 1.5 then
                        msec = 0
                        DrawMarker(2, vector3(v.vehicle.x, v.vehicle.y, v.vehicle.z + 1.0), 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.3, 0.3, -0.22, 220, 0, 0, 100, false, true, 2, true)
                        if IsPedInAnyVehicle(playerPed) then
                            DrawTxt(vector3(v.vehicle.x, v.vehicle.y, v.vehicle.z + 1.0), Locales[idioma]['vehicle_delete'], 0.7, 0)
                            if IsControlJustPressed(0, 38) then
                                DeleteEntity(GetVehiclePedIsIn(playerPed))
                            end
                        else
                            DrawTxt(vector3(v.vehicle.x, v.vehicle.y, v.vehicle.z + 1.0), Locales[idioma]['vehicle_menu'], 0.7, 0)
                            if IsControlJustPressed(0, 38) then
                                TriggerServerEvent('Roda_GangsCreator:server:RequestVehicles', v.gang)
                            end
                        end
                    elseif #(playerCoords - vector3(v.vehicle.x, v.vehicle.y, v.vehicle.z)) < 5.0 then
                        msec = 0
                        DrawMarker(2, vector3(v.vehicle.x, v.vehicle.y, v.vehicle.z + 1.0), 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.3, 0.3, -0.22, 220, 0, 0, 100, false, true, 2, true)
                    end

                    if gang_grade == 3 then
                        if #(playerCoords - vector3(v.bossmenu.x, v.bossmenu.y, v.bossmenu.z)) < 1.5 then
                            msec = 0
                            DrawMarker(2, vector3(v.bossmenu.x, v.bossmenu.y, v.bossmenu.z + 1.0), 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.3, 0.3, -0.22, 220, 0, 0, 100, false, true, 2, true)
                            DrawTxt(vector3(v.bossmenu.x, v.bossmenu.y, v.bossmenu.z + 1.0), Locales[idioma]['boss_menu'], 0.7, 0)
                            if IsControlJustPressed(0, 38) then
                                TriggerServerEvent('Roda_GangsCreator:server:RequestMembers', v.gang)
                            end
                        elseif #(playerCoords - vector3(v.bossmenu.x, v.bossmenu.y, v.bossmenu.z)) < 5.0 then
                            msec = 0
                            DrawMarker(2, vector3(v.bossmenu.x, v.bossmenu.y, v.bossmenu.z + 1.0), 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.3, 0.3, -0.22, 220, 0, 0, 100, false, true, 2, true)
                        end
                    end
                end
            end
        end
        Wait(msec)
    end
end)

RegisterNetEvent('Roda_GangsCreator:client:RequestMembers')
AddEventHandler('Roda_GangsCreator:client:RequestMembers', function(members)
    SetNuiFocus(true, true)

    for k,v in pairs(members) do
        SendNUIMessage({
            action = 'openBossMenu',
            name = v.firstname.. ' ' ..v.lastname,
            identifier = v.identifier,
        })
    end
end)

RegisterNetEvent('Roda_GangsCreator:client:RequestVehicles')
AddEventHandler('Roda_GangsCreator:client:RequestVehicles', function(vehicles)
    SetNuiFocus(true, true)
    for k,v in pairs(vehicles) do
        SendNUIMessage({
            action = 'openGarage',
            name = v.name,
            label = v.label,
        })
    end
end)

RegisterNUICallback('clothes', function(data, cb)
    local sexo = GetSex()
    TriggerServerEvent('Roda_GangsCreator:server:RequestClothesForPlayer', data.skin, gang, sexo)
end)

RegisterNetEvent('Roda_GangsCreator:client:RequestClothesForPlayer')
AddEventHandler('Roda_GangsCreator:client:RequestClothesForPlayer', function (skin)
    PutClothes(skin)
end)


RegisterNetEvent('Roda_GangsCreator:client:RequestClothes')
AddEventHandler('Roda_GangsCreator:client:RequestClothes', function(clothes)
    SetNuiFocus(true, true)
    for k,v in pairs(clothes) do
        SendNUIMessage({
            action = 'openClothes',
            label = v.label,
            skin = v.skin,
            name = v.name
        })
    end
end)

RegisterNetEvent('Roda_GangsCreator:client:sendNotification')
AddEventHandler('Roda_GangsCreator:client:sendNotification', function(message)
    Notification(message)
end)

RegisterNUICallback('SetNewRange', function(data, cb)
    if data.rango == 'null' then
        Notification(Locales[idioma]['gang_range_null'])
    else
        TriggerServerEvent('Roda_GangsCreator:server:SetNewRange', data.identifier, tonumber(data.rango))
        Notification(Locales[idioma]['gang_range_set']:format(data.nombre))
    end

end)

RegisterNUICallback('spawnVehicle', function(data, cb)
    local playerPed = PlayerPedId()
    local coords = GetEntityCoords(playerPed)
    local heading = GetEntityHeading(playerPed)
    local model = GetHashKey(data.model)

    RequestModel(model)
    while not HasModelLoaded(model) do
        Wait(50)
    end

    local vehicle = CreateVehicle(model, coords.x, coords.y, coords.z, true, true)
    while not DoesEntityExist(vehicle) do
        Wait(50)
    end

    SetVehicleOnGroundProperly(vehicle)
    SetEntityHeading(vehicle, heading)
    SetVehicleNumberPlateText(vehicle, 'RODA')
    TaskWarpPedIntoVehicle(playerPed, vehicle, -1)
    local name = GetLabelText(GetDisplayNameFromVehicleModel(model))
    if name == 'NULL' then
        name = data.model
    end
    Notification(Locales[idioma]['vehicle_spawned']:format(name))
    SendNUIMessage({
        action = 'closeAll'
    })
end)

RegisterNUICallback('saveVehicleInDataBase', function(data, cb)
    if IsModelInCdimage(GetHashKey(data.model)) then
        local name = GetLabelText(GetDisplayNameFromVehicleModel(data.model))
        if name == 'NULL' then
            name = data.model
        end

        TriggerServerEvent('Roda_GangsCreator:server:AddNewCar', data.gang, data.model, data.label)
        ErrorNoti(Locales[idioma]['add_vehicle']:format(data.model, data.labelGang), 2000, 'Success')
    else
        ErrorNoti(Locales[idioma]['error_vehicle'], 2000, 'ERROR')
    end
end)

RegisterNUICallback('getSkin', function(data, cb)

    if data.skin == 'male' then
        TriggerEvent('skinchanger:getSkin', function(skin)
            TriggerServerEvent('Roda_GangsCreator:server:SaveOutfit', data.skin, data.label, skin, data.gang)
        end)
        if data.label == 'none' then
            ErrorNoti(Locales[idioma]['save_outfit'], 2000, 'Success')
        else
            ErrorNoti(Locales[idioma]['male_outfit']:format(data.label), 2000, 'Success')
        end
    else
        TriggerEvent('skinchanger:getSkin', function(skin)
            TriggerServerEvent('Roda_GangsCreator:server:SaveOutfit', data.skin, data.label, skin, data.gang)
        end)
        if data.label == 'none' then 
            ErrorNoti(Locales[idioma]['save_outfit'], 2000, 'Success')
        else
            ErrorNoti(Locales[idioma]['female_outfit']:format(data.label), 2000, 'Success')
        end
    end
end)

RegisterNetEvent('Roda_GangsCreator:SendBoss')
AddEventHandler('Roda_GangsCreator:SendBoss', function ()
    getPlayers()
end)

RegisterNUICallback('sendNewMember', function(data, cb)
    if data.option == 'null' then
        Notification(Locales[idioma]['gang_range_null'])
    else
        TriggerServerEvent('Roda_GangsCreator:server:AddNewMember', data.pid, data.name, data.option, gang)
        -- Notification(Locales[idioma]['gang_member_added']:format(data.name))
        SendNUIMessage({
            action = 'closeAll'
        })
    end
end)


RegisterNetEvent('Roda_GangsCreator:client:sendInvitation')
AddEventHandler('Roda_GangsCreator:client:sendInvitation', function (src, target, gangreclute, range, label)
    SetNuiFocus(true, true)
    SendNUIMessage({
        action = 'openInvitation',
        src = src,
        target = target,
        gang = gangreclute,
        range = range,
        label = label
    })
end)

RegisterNUICallback('acceptNewMember', function(data, cb)
    SendNUIMessage({
        action = 'closeAll'
    })
    TriggerServerEvent('Roda_GangsCreator:server:AcceptNewMember', data.jefe, data.target, data.gang, data.rango)
end)

RegisterNUICallback('deniedMember', function(data, cb)
    SendNUIMessage({
        action = 'closeAll'
    })
    TriggerServerEvent('Roda_GangsCreator:server:DeniedNewMember', data.jefe, data.target, data.gang, data.rango)
end)

RegisterNUICallback('DeleteNewRange', function(data, cb)
    SendNUIMessage({
        action = 'closeAll'
    })
    TriggerServerEvent('Roda_GangsCreator:client:DeleteNewRange', data.identifier)
end)



RegisterCommand('Ns', function ()
    local mugshot, mugshotStr = ESX.Game.GetPedMugshot(PlayerPedId())
    SendNUIMessage({
        action = 'pruebaxd',
        texture = mugshotStr
    })
end)

RegisterNUICallback('GetIdentity', function(data, cb)
     local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()
    
     if closestPlayer ~= -1 and closestDistance <= 3.0 then
         TriggerServerEvent('Roda_GangsCreator:server:GetIdentity', GetPlayerServerId(closestPlayer))
     else
         Notification(Locales[idioma]['no_nearby'],'error')
     end
end)

RegisterNetEvent('Roda_GangsCreator:client:GetIdentity')
AddEventHandler('Roda_GangsCreator:client:GetIdentity', function (target, data)

    local playerPed = GetPlayerPed(GetPlayerFromServerId(target))
	local handle = RegisterPedheadshot(playerPed)
    while not IsPedheadshotReady(handle) do
		Wait (100)
	end
	local headshot = GetPedheadshotTxdString (handle)
    SendNUIMessage({
        action = 'openIdentity',
        datos = data,
        foto = headshot
    })
end)

