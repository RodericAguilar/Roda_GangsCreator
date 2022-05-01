function DisableDisplayControlActions()
    DisableControlAction(0, 1, true) -- disable mouse look
    DisableControlAction(0, 2, true) -- disable mouse look
    DisableControlAction(0, 3, true) -- disable mouse look
    DisableControlAction(0, 4, true) -- disable mouse look
    DisableControlAction(0, 5, true) -- disable mouse look
    DisableControlAction(0, 6, true) -- disable mouse look
    DisableControlAction(0, 263, true) -- disable melee
    DisableControlAction(0, 264, true) -- disable melee
    DisableControlAction(0, 257, true) -- disable melee
    DisableControlAction(0, 140, true) -- disable melee
    DisableControlAction(0, 141, true) -- disable melee
    DisableControlAction(0, 142, true) -- disable melee
    DisableControlAction(0, 143, true) -- disable melee
    DisableControlAction(0, 177, true) -- disable escape
    DisableControlAction(0, 200, true) -- disable escape
    DisableControlAction(0, 202, true) -- disable escape
    DisableControlAction(0, 322, true) -- disable escape
    DisableControlAction(0, 245, true) -- disable chat
    DisableControlAction(0, 37, true) -- disable TAB
    DisableControlAction(0, 261, true) -- disable mouse wheel
    DisableControlAction(0, 262, true) -- disable mouse wheel
    HideHudComponentThisFrame(19)
end

local handcuffed = false
local dragStatus = {}
dragStatus.isDragged = false

RegisterNetEvent('Roda_GangsCreator:client:handcuff')
AddEventHandler('Roda_GangsCreator:client:handcuff', function()
    local playerPed = PlayerPedId()
    handcuffed = not handcuffed

    if handcuffed then
        handcuffed = true
		RequestAnimDict('mp_arresting')
		while not HasAnimDictLoaded('mp_arresting') do
			Wait(100)
		end

		TaskPlayAnim(playerPed, 'mp_arresting', 'idle', 8.0, -8, -1, 49, 0, 0, 0, 0)

        SetEnableHandcuffs(playerPed, true)
		SetCurrentPedWeapon(playerPed, GetHashKey('WEAPON_UNARMED'), true) -- unarm player
		SetPedCanPlayGestureAnims(playerPed, false)
        CreateThread(function()
            while handcuffed do
                Wait(0)
                DisablePlayerFiring(playerPed, true)
                DisableControlAction(0, 263, true) -- disable melee
                DisableControlAction(0, 264, true) -- disable melee
                DisableControlAction(0, 257, true) -- disable melee
                DisableControlAction(0, 140, true) -- disable melee
                DisableControlAction(0, 141, true) -- disable melee
                DisableControlAction(0, 142, true) -- disable melee
                DisableControlAction(0, 143, true) -- disable melee
                DisableControlAction(0, 177, true) -- disable escape
                DisableControlAction(0, 200, true) -- disable escape
                DisableControlAction(0, 202, true) -- disable escape
                DisableControlAction(0, 322, true) -- disable escape
                DisableControlAction(0, 245, true) -- disable chat
                DisableControlAction(0, 37, true) -- disable TAB
                DisableControlAction(0, 261, true) -- disable mouse wheel
                DisableControlAction(0, 262, true) -- disable mouse wheel
                HideHudComponentThisFrame(19)
            end
        end)
    else
        handcuffed = false
		ClearPedSecondaryTask(playerPed)
		SetEnableHandcuffs(playerPed, false)
		DisablePlayerFiring(playerPed, false)
		SetPedCanPlayGestureAnims(playerPed, true)
    end
end)

RegisterNetEvent('Roda_GangsCreator:client:drag')
AddEventHandler('Roda_GangsCreator:client:drag', function(copId)
	if handcuffed then
		dragStatus.isDragged = not dragStatus.isDragged
		dragStatus.CopId = copId
	end
end)

CreateThread(function()
	local wasDragged

	while true do
		Wait(0)
		local playerPed = PlayerPedId()

		if handcuffed and dragStatus.isDragged then
			local targetPed = GetPlayerPed(GetPlayerFromServerId(dragStatus.CopId))

			if DoesEntityExist(targetPed) and IsPedOnFoot(targetPed) and not IsPedDeadOrDying(targetPed, true) then
				if not wasDragged then
					AttachEntityToEntity(playerPed, targetPed, 11816, 0.54, 0.54, 0.0, 0.0, 0.0, 0.0, false, false, false, false, 2, true)
					wasDragged = true
				else
					Wait(1000)
				end
			else
				wasDragged = false
				dragStatus.isDragged = false
				DetachEntity(playerPed, true, false)
			end
		elseif wasDragged then
			wasDragged = false
			DetachEntity(playerPed, true, false)
		else
			Wait(500)
		end
	end
end)

function OpenOutfits(gang)
	local sex = GetSex()
	TriggerServerEvent('Roda_GangsCreator:server:RequestClothes', sex, gang)
end

function RayCastGamePlayCamera(distance)
    -- https://github.com/Risky-Shot/new_banking/blob/main/new_banking/client/client.lua
    local cameraRotation = GetGameplayCamRot()
	local cameraCoord = GetGameplayCamCoord()
	local direction = RotationToDirection(cameraRotation)
	local destination =
	{
		x = cameraCoord.x + direction.x * distance,
		y = cameraCoord.y + direction.y * distance,
		z = cameraCoord.z + direction.z * distance
	}
	local a, b, c, d, e = GetShapeTestResult(StartShapeTestRay(cameraCoord.x, cameraCoord.y, cameraCoord.z, destination.x, destination.y, destination.z, -1, PlayerPedId(), 0))
	return b, c, e
end

function RotationToDirection(rotation)
    -- https://github.com/Risky-Shot/new_banking/blob/main/new_banking/client/client.lua
	local adjustedRotation =
	{
		x = (math.pi / 180) * rotation.x,
		y = (math.pi / 180) * rotation.y,
		z = (math.pi / 180) * rotation.z
	}
	local direction =
	{
		x = -math.sin(adjustedRotation.z) * math.abs(math.cos(adjustedRotation.x)),
		y = math.cos(adjustedRotation.z) * math.abs(math.cos(adjustedRotation.x)),
		z = math.sin(adjustedRotation.x)
	}
	return direction
end


function ErrorNoti(message, timeout, title)
	SendNUIMessage({
		action = "showNoti",
		message = message,
		timeout = timeout,
		title = title
	})
end



function PlayAnim(Dict, Anim, Flag)
    LoadDict(Dict)
    TaskPlayAnim(PlayerPedId(), Dict, Anim, 8.0, -8.0, -1, Flag or 0, 0, false, false, false)
end

function LoadDict(Dict)
    while not HasAnimDictLoaded(Dict) do
        Wait(0)
        RequestAnimDict(Dict)
    end
end

function getPlayers()
    local playerPed = PlayerPedId()
    local playersNearby = ESX.Game.GetPlayersInArea(GetEntityCoords(playerPed), 3.0)

    if #playersNearby > 0 then
        local players = {}
        elements = {}

        for k,playerNearby in ipairs(playersNearby) do
            players[GetPlayerServerId(playerNearby)] = true
        end

        ESX.TriggerServerCallback('esx:getPlayerNames', function(returnedPlayers)
            for playerId,playerName in pairs(returnedPlayers) do
                table.insert(elements, {
                    label = playerName,
                    playerId = playerId
                })
            end

            for k,v in pairs(elements) do
				SendNUIMessage({
					action = 'recluteNewMember',
					label = v.label,
					playerId = v.playerId
				})
				SetNuiFocus(true, true)
            end
        end, players)
    else
        Notification(Locales[idioma]['no_nearby'])
    end
end
