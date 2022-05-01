Config = {}

Config.Admins = {
    'mod',
    'admin',
    'superadmin'
}

Config.Language = 'en' -- en or es  -- Check Language.lua to add more.

Config.Db = 'oxmysql' -- mysql or ghmattisql or oxmysql (just 1.9), if u use oxmysql 2.0+ put mysql here.

Config.Inventory = 'ox_inventory' -- ox_inventory, chezza, quasar or custom

Config.Notification = 'default' -- default or roda (https://github.com/RodericAguilar/Roda_Notifications) or custom


function OpenSearchMenu(user) -- User return Source, so if your trigger that use GetPlayerServerId(user) just put user.
    if Config.Inventory == 'ox_inventory' then
        exports.ox_inventory:openInventory('player', user)
    elseif Config.Inventory == 'chezza' then
        TriggerEvent('inventory:openPlayerInventory', user) -- Just V3
    elseif Config.Inventory == 'quasar' then
        TriggerServerEvent("inventory:server:OpenInventory", "otherplayer", user)
    elseif Config.Inventory == 'custom' then
        -- Trigger here.
    else
        print('Inventory not found')
    end
end

function OpenStash(gang)
	if Config.Inventory == 'ox_inventory' then
        exports.ox_inventory:openInventory('stash', {id = gang.. '-stash'})
    elseif Config.Inventory == 'chezza' then
        TriggerEvent('inventory:Roda_GangsCreator', gang)  -- Just V3
    elseif Config.Inventory == 'quasar' then
        TriggerServerEvent ("inventory:server:OpenInventory", "stash", gang.. '-stash')
    elseif Config.Inventory == 'custom' then 
        -- Custom Event
    else
        print('Inventory not found')
    end
end

function Notification(text, type, timeout)
    if not timeout then
        timeout = 5000
    end
    if not type then 
        type = 'normal'
    end

    if Config.Notification == 'default' then
        SetNotificationTextEntry('STRING')
        AddTextComponentString(text)
        DrawNotification(false, false)
    elseif Config.Notification == 'roda' then
        exports['Roda_Notifications']:showNotify(text, type, timeout)
    elseif Config.Notification == 'custom' then
        -- your custom notification
    else
        print('Notification not found')
    end
end

function GetSex()
    local sexo = nil
    -- you can change this to your functions
    ESX.TriggerServerCallback('esx_skin:getPlayerSkin', function(skin, jobSkin)
        if skin.sex == 0 then
            sexo = 'male'
        else
            sexo = 'female'
        end
    end)
    Wait(200)
    return sexo
end

function PutClothes(name)
    TriggerEvent('skinchanger:getSkin', function(skin)
        PlayAnim('mp_safehouseshower@male@', 'male_shower_towel_dry_to_get_dressed', 0)
        Wait(10000)
        TriggerEvent('skinchanger:loadClothes', skin, name)
        TriggerEvent('esx_skin:setLastSkin', skin)
        TriggerEvent('skinchanger:getSkin', function(skin)
        TriggerServerEvent('esx_skin:save', skin)
        end)
    end)
    --Close menu 
    SendNUIMessage({
        action = 'closeAll'
    })
end