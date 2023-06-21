
local QBCore = exports['qb-core']:GetCoreObject() 				

local activeDrops = {}

RegisterNetEvent('d_gunheist:manipulateDrop')
AddEventHandler('d_gunheist:manipulateDrop', function(dropId, dropData)
	if not dropData then
		if activeDrops[dropId].blip and DoesBlipExist(activeDrops[dropId].blip) then
			RemoveBlip(activeDrops[dropId].blip)
		end

		if activeDrops[dropId].object then
			SetEntityAsMissionEntity(activeDrops[dropId].object, true, true)
			DeleteObject(activeDrops[dropId].object)
		end
	end

	activeDrops[dropId] = dropData
end)

RegisterNetEvent('d_gunheist:obtainDrops')
AddEventHandler('d_gunheist:obtainDrops', function(serverDrops)
	activeDrops = serverDrops
end)

-- Guardas

liGuards = {
    ['npcguards'] = {}
}

function loadModel(model)
    if type(model) == 'number' then
        model = model
    else
        model = GetHashKey(model)
    end
    while not HasModelLoaded(model) do
        RequestModel(model)
        Citizen.Wait(0)
    end
end

function SpawnGuards()
	local ped = PlayerPedId()

	SetPedRelationshipGroupHash(ped, `PLAYER`)
	AddRelationshipGroup('npcguards')

	for k, v in pairs(Config['liGuards']['npcguards']) do
        loadModel(v['model'])
		liGuards['npcguards'][k] = CreatePed(26, GetHashKey(v['model']), v['coords'], v['heading'], true, true)
		NetworkRegisterEntityAsNetworked(liGuards['npcguards'][k])
		networkID = NetworkGetNetworkIdFromEntity(liGuards['npcguards'][k])
		SetNetworkIdCanMigrate(networkID, true)
		SetNetworkIdExistsOnAllMachines(networkID, true)
		SetPedRandomComponentVariation(liGuards['npcguards'][k], 0)
		SetPedRandomProps(liGuards['npcguards'][k])
		SetEntityAsMissionEntity(liGuards['npcguards'][k])
		SetEntityVisible(liGuards['npcguards'][k], true)
		SetPedRelationshipGroupHash(liGuards['npcguards'][k], `npcguards`)
		SetPedAccuracy(liGuards['npcguards'][k], 75)
		SetPedArmour(liGuards['npcguards'][k], 100)
		SetPedCanSwitchWeapon(liGuards['npcguards'][k], true)
		SetPedDropsWeaponsWhenDead(liGuards['npcguards'][k], false)
		SetPedFleeAttributes(liGuards['npcguards'][k], 0, false)
		GiveWeaponToPed(liGuards['npcguards'][k], Config.npcWeapon, 255, false, false)
		TaskGoToEntity(liGuards['npcguards'][k], PlayerPedId(), -1, 1.0, 10.0, 1073741824.0, 0)
		local random = math.random(1, 2)
		if random == 2 then
			TaskGuardCurrentPosition(liGuards['npcguards'][k], 10.0, 10.0, 1)
		end
	end

	SetRelationshipBetweenGroups(0, `npcguards`, `npcguards`)
	SetRelationshipBetweenGroups(5, `npcguards`, `PLAYER`)
	SetRelationshipBetweenGroups(5, `PLAYER`, `npcguards`)
end

RegisterNetEvent('d_gunheist:createBlipOnDrop')
AddEventHandler('d_gunheist:createBlipOnDrop', function(dropId)
	while not activeDrops[dropId] do
		Citizen.Wait(0)
	end

	local coords = Config.pickupLocations[activeDrops[dropId].pickupLocation]

	activeDrops[dropId].blip = AddBlipForCoord(coords)

	SetBlipSprite(activeDrops[dropId].blip, 478)
	SetBlipScale(activeDrops[dropId].blip, 0.9)
	SetBlipColour(activeDrops[dropId].blip, 0)
	SetBlipDisplay(activeDrops[dropId].blip, 4)
	SetBlipAsShortRange(activeDrops[dropId].blip, false)

	BeginTextCommandSetBlipName('STRING')
	AddTextComponentString('Weapon Crate')
	EndTextCommandSetBlipName(activeDrops[dropId].blip)

	SetNewWaypoint(coords.x, coords.y)

	if Config.npcSpawn == true then
		SpawnGuards()
	end
end)

-- Gun Crate Robbery Disptach Notification (ps-dispatch) --
function Dispatch()
    exports['ps-dispatch']:gunCreateRobbery()
end

function ScanActiveDrops()
	local coords = GetEntityCoords(PlayerPedId())
	local closest = 1000
	local id

	for dropId, dropData in pairs(activeDrops) do
		local dstcheck = #(coords - Config.pickupLocations[dropData.pickupLocation])

		if dstcheck < closest then
			closest = dstcheck
			id = dropId
		end
	end

	return closest, id
end

function DrawText3Ds(x, y, z, text)
	local onScreen,_x,_y=World3dToScreen2d(x,y,z)

	if onScreen then
		SetTextScale(0.35, 0.35)
		SetTextFont(4)
		SetTextProportional(1)
		SetTextColour(255, 255, 255, 215)
		SetTextEntry("STRING")
		SetTextCentre(1)
		AddTextComponentString(text)
		DrawText(_x,_y)
		local factor = (string.len(text)) / 370
		DrawRect(_x,_y+0.0125, 0.015+ factor, 0.03, 41, 11, 41, 68)
	end
end

local inAnimation = false

RegisterNetEvent('d_gunheist:openCrate')
AddEventHandler('d_gunheist:openCrate', function(crateObject)
	LoadAnimDict("amb@medic@standing@tendtodead@enter")
	LoadAnimDict("amb@medic@standing@tendtodead@idle_a")

	local ped = PlayerPedId()

	TaskTurnPedToFaceEntity(ped, crateObject, 1000)
	Citizen.Wait(1000)
	TaskPlayAnim(ped, "amb@medic@standing@tendtodead@enter", "enter", 1.0, 1.0, -1, 8, -1, 0, 0, 0)
	Citizen.Wait(800)
	TaskPlayAnim(ped, "amb@medic@standing@tendtodead@idle_a", "idle_a", 1.0, 1.0, -1, 9, -1, 0, 0, 0)

	while inAnimation do
		Citizen.Wait(1)

		DisableControlAction(0, 161)
		DisableControlAction(0, 311)

		if not IsEntityPlayingAnim(ped, 'amb@medic@standing@tendtodead@idle_a', 'idle_a', 3) then
			TaskPlayAnim(ped, 'amb@medic@standing@tendtodead@idle_a', 'idle_a', 1.0, 1.0, -1, 9, -1, 0, 0, 0)
		end
	end

	ClearPedTasks(PlayerPedId())

	RemoveAnimDict("amb@medic@standing@tendtodead@enter")
	RemoveAnimDict("amb@medic@standing@tendtodead@idle_a")
end)

Citizen.CreateThread(function()
	TriggerServerEvent('d_gunheist:obtainDrops')

	while true do
		local dropDistance, dropId = ScanActiveDrops()

		if dropDistance < 2.5 then
			local coords = Config.pickupLocations[activeDrops[dropId].pickupLocation]

			if dropDistance < 1.5 then
				DrawText3Ds(coords.x, coords.y, coords.z, "[E] Drill Crate")

				if IsControlJustReleased(0, 38) then
					TriggerServerEvent('checkDrill', dropId)
				end
			else
				DrawText3Ds(coords.x, coords.y, coords.z, "Drill Crate")
			end
		else
			Citizen.Wait(math.ceil(dropDistance * 20))
		end

		Citizen.Wait(0)
	end
end)


RegisterNetEvent('do')
AddEventHandler('do', function(dropId)
	inAnimation = true

	TriggerEvent('d_gunheist:openCrate', activeDrops[dropId].object)

	if Config.enablePolice == true then
		local pdalert = math.random(1, 100)

		if Config.policeAlert >= pdalert then
			Dispatch()
		end
	end
	
	QBCore.Functions.Progressbar("drilling_", "Drilling...", Config.drillTime, false, true, {}, {}, {}, {}, function()
		TriggerServerEvent('d_gunheist:pickUpDrop', dropId)
		inAnimation = false
	end)
end) 


function LoadModel(model)
	if not HasModelLoaded(model) then
		RequestModel(model)

		while not HasModelLoaded(model) do
			Citizen.Wait(1)
		end
	end
end

AddEventHandler("onResourceStop", function(resource)
	if resource == GetCurrentResourceName() then
		for dropId, dropData in pairs(activeDrops) do
			if dropData.object and DoesEntityExist(dropData.object) then
				SetEntityAsMissionEntity(dropData.object, true, true)
				DeleteObject(dropData.object)
			end
		end
	end
end)

RegisterNetEvent('clearTasks')
AddEventHandler('clearTasks', function() 
	ClearPedTasks(PlayerPedId())
end)

Citizen.CreateThread(function()
	local modelHash = GetHashKey("gr_prop_gr_rsply_crate04a")

	while true do
		local coords = GetEntityCoords(PlayerPedId())

		for dropId, dropData in pairs(activeDrops) do
			local dstcheck = #(coords - Config.pickupLocations[dropData.pickupLocation])

			if dstcheck < 100 and not dropData.object then
				LoadModel(modelHash)
				local coords = Config.pickupLocations[activeDrops[dropId].pickupLocation]
				activeDrops[dropId].object = CreateObject(modelHash, coords.x, coords.y, coords.z - 1.0, false, false, false)
				SetModelAsNoLongerNeeded(modelHash)

				FreezeEntityPosition(activeDrops[dropId].object, true)
			elseif dstcheck > 100 and dropData.object then
				if DoesEntityExist(dropData.object) then
					SetEntityAsMissionEntity(dropData.object, true, true)
					DeleteObject(dropData.object)
				end

				activeDrops[dropId].object = nil
			end
		end

		Citizen.Wait(1000)
	end
end)

RegisterNetEvent('d_gunheist:useChip')

AddEventHandler('d_gunheist:useChip', function()
	local dstcheck = #(GetEntityCoords(PlayerPedId()) - Config.hackingPosition)

	-- TriggerServerEvent('d_gunheist:policeCheck')

	if dstcheck < 5 then
		if StartHacking() then
			TriggerServerEvent('d_gunheist:wonHacking')
		end
	end
end)



function LoadAnimDict(dict)
	if not HasAnimDictLoaded(dict) then
		RequestAnimDict(dict)

		while not HasAnimDictLoaded(dict) do
			Citizen.Wait(1)
		end
	end
end


RegisterNetEvent('opguns:doDecryptionAnimation')
AddEventHandler('d_gunheist:doDecryptionAnimation', function()
	local ped = PlayerPedId()
	RequestAnimDict('missheist_jewel@hacking')
	TaskPlayAnim(ped, "missheist_jewel@hacking", "hack_loop", 8.0, 1.0, -1, 9, 0, 0, 0, 0)
end)

RegisterNetEvent('d_gunheist:useDecryptionKey')
AddEventHandler('d_gunheist:useDecryptionKey', function(item)
	local dstcheck = #(GetEntityCoords(PlayerPedId()) - Config.hackingPosition)
	-- print(item)
	if dstcheck < 5 then
		TriggerEvent('d_gunheist:doDecryptionAnimation')


		QBCore.Functions.Progressbar("drilling_", "Decrypting with key...", Config.decryptTime, false, true, {}, {}, {}, {}, function()
			ClearPedTasks(PlayerPedId())
			RemoveAnimDict("missheist_jewel@hacking")
			TriggerServerEvent('d_gunheist:server:useDecryptionKey', item)
		end)
	end
end)

function hackingCompleted(success, timeremaining)
	if success then
		TriggerServerEvent('d_gunheist:hackingCompleted')
	end
	TriggerEvent(Config.hackScript .. ':hide')
end

RegisterNetEvent('d_gunheist:hackingMinigame')
AddEventHandler('d_gunheist:hackingMinigame', function()
	TriggerEvent(Config.hackScript .. ":show")
	TriggerEvent(Config.hackScript .. ":start", 7, 20, hackingCompleted)
end)
