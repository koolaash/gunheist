local firstTile = 'Gun'
local secondTile = 'Heist'
local scriptName = 'V2.0'

print('^2▄▄▄▄▄▄  ▄▄▄▄▄▄▄ ▄▄   ▄▄ ▄▄▄▄▄▄▄ ▄▄    ▄▄▄^7')
print('^2█      ██       █  █▄█  █       █  █  █ █^7')
print('^2█  ▄    █   ▄   █       █   ▄   █   █▄█ █^7')
print('^2█ █ █   █  █▄█  █       █  █ █  █       █^7')
print('^2█ █▄█   █       █       █  █▄█  █  ▄    █^7')
print('^2█       █   ▄   █ ██▄██ █       █ █ █   █^7')
print('^2█▄▄▄▄▄▄██▄▄█ █▄▄█▄█   █▄█▄▄▄▄▄▄▄█▄█  █▄▄█^7')
print("^2" .. firstTile .. "^7-^2" .. secondTile .. "^7 ^2" .. scriptName .. " Script by ^1Damon 🖤#6667^7")

Citizen.CreateThread(function()
    SetConvarServerInfo(firstTile .. " " .. secondTile, "Damon")
end)

local QBCore = exports['qb-core']:GetCoreObject()

local keys = {
	[1] = {label = "Red Decryption Key", itemName = "d_redchip", colorId = 1},
	[2] = {label = "Green Decryption Key", itemName = "d_greenchip", colorId = 6},
	[3] = {label = "Blue Decryption Key", itemName = "d_bluechip", colorId = 2},
}

local activeKeys = {}
local keysUsed = 0
local delayKeyChange = false
local weaponDropped = false

local heistId = 0

local totalChances = 0
local pickupLocations = 415

local activeDrops = {}
local dropIds = 0

Citizen.CreateThread(function()
	for i = 1, #Config.dropItems do
		totalChances = totalChances + Config.dropItems[i].chance
	end
end)

RegisterServerEvent('d_gunheist:wonHacking')
AddEventHandler('d_gunheist:wonHacking', function()
	local src = source
	local Player = QBCore.Functions.GetPlayer(src)
	local chipSlot = Player.Functions.GetItemByName('d_hak_kit2')
	local firstcolor = keys[activeKeys[1]].colorId
	local secondcolor = keys[activeKeys[2]].colorId
	local thirdcolor = keys[activeKeys[3]].colorId
	if Player then
		if chipSlot.amount > 0 then
			delayKeyChange = true
			
			if firstcolor == 6 then
				TriggerClientEvent('chatMessage', source, "FIRST", "report",  keys[activeKeys[1]].label)
			elseif firstcolor == 2 then
				TriggerClientEvent('chatMessage', source,"FIRST", "normal", keys[activeKeys[1]].label)
			elseif firstcolor == 1 then
				TriggerClientEvent('chatMessage', source, "FIRST", "error", keys[activeKeys[1]].label)
			end

			if secondcolor == 6 then
				TriggerClientEvent('chatMessage', source, "SECOND", "report",  keys[activeKeys[2]].label)
			elseif secondcolor == 2 then
				TriggerClientEvent('chatMessage', source,"SECOND", "normal", keys[activeKeys[2]].label)
			elseif secondcolor == 1 then
				TriggerClientEvent('chatMessage', source, "SECOND", "error", keys[activeKeys[2]].label)
			end

			if thirdcolor == 6 then
				TriggerClientEvent('chatMessage', source, "THIRD", "report",  keys[activeKeys[3]].label)
			elseif thirdcolor == 2 then
				TriggerClientEvent('chatMessage', source,"THIRD", "normal", keys[activeKeys[3]].label)
			elseif thirdcolor == 1 then
				TriggerClientEvent('chatMessage', source, "THIRD", "error", keys[activeKeys[3]].label)
			end
		end
	end
end)


 
RegisterServerEvent('d_gunheist:server:useDecryptionKey')
AddEventHandler('d_gunheist:server:useDecryptionKey', function(item)
	local src = source
	local Player = QBCore.Functions.GetPlayer(src)
	

	if Player then
		local keySlot = Player.Functions.GetItemByName(item)

		if keySlot.amount > 0 then
			Player.Functions.RemoveItem(item, 1)
			delayKeyChange = true
			if keys[activeKeys[keysUsed + 1]].itemName == item then
				keysUsed = keysUsed + 1
				if keysUsed == 3 then
					TriggerClientEvent('d_gunheist:hackingMinigame', src)
				else
					TriggerClientEvent('QBCore:Notify', src, "Correct key!")
				end
			else
				TriggerClientEvent('QBCore:Notify', src, "Wrong key!", "error")
			end
		end
	end
end)

RegisterServerEvent('d_gunheist:createHeistLoop')
AddEventHandler('d_gunheist:createHeistLoop', function()
	heistId = heistId + 1

	local thisId = heistId

	Citizen.CreateThread(function()
		keysUsed = 0
		weaponDropped = false

		local key1 = math.random(3)
		local key2
		local key3

		while not key2 or not key3 do
			local possibleKey = math.random(3)

			if not key2 and possibleKey ~= key1 then
				key2 = possibleKey
			end

			if possibleKey ~= key1 and possibleKey ~= key2 then
				key3 = possibleKey
			end

			Citizen.Wait(0)
		end

		activeKeys = {key1, key2, key3}
	end)

	Citizen.Wait(300000)

	if heistId == thisId then
		if delayKeyChange then
			Citizen.Wait(300000)
			delayKeyChange = false
		end

		if heistId == thisId then
			TriggerEvent('d_gunheist:createHeistLoop')
		end
	end
end)

RegisterServerEvent('d_gunheist:obtainDrops')
AddEventHandler('d_gunheist:obtainDrops', function()
	TriggerClientEvent('d_gunheist:obtainDrops', source, activeDrops)
end)


RegisterServerEvent('checkDrill')

AddEventHandler('checkDrill', function(dropId) 
	local src = source
	local Player = QBCore.Functions.GetPlayer(src)
	local drill = Player.Functions.GetItemByName(Config.drill)
	if drill ~= nil and drill.amount > 0 then
		TriggerClientEvent('do', src, dropId)
	else
		TriggerClientEvent('QBCore:Notify', src, 'you have no drill!', 'error')
	end
end)

RegisterServerEvent('d_gunheist:pickUpDrop')
AddEventHandler('d_gunheist:pickUpDrop', function(dropId)
	local src = source
	local Player = QBCore.Functions.GetPlayer(src)
	local drillSlot = Player.Functions.GetItemByName(Config.drill)

	if activeDrops[dropId] then

		if Player then
			if drillSlot ~= nil and drillSlot.amount >= 1 then
				Player.Functions.RemoveItem(Config.drill, 1)
				local dropData = activeDrops[dropId]

				activeDrops[dropId] = nil

				for i = 1 , Config.multipleReward do
					Player.Functions.AddItem(dropData.itemName, 1)
				end

				TriggerClientEvent('QBCore:Notify', src, "Picked up " .. dropData.label)
				TriggerClientEvent('clearTasks', src)

				TriggerClientEvent('d_gunheist:manipulateDrop', -1, dropId)
			else
				TriggerClientEvent("QBCore:Notify", src, "You need to have a drill on you...", "error")
			end
		end
	end
end)

RegisterServerEvent('d_gunheist:hackingCompleted')
AddEventHandler('d_gunheist:hackingCompleted', function()
	local src = source

	if not weaponDropped then
		weaponDropped = true

		local itemLottery = math.random(totalChances)
		local loopedThrough = 0
		local item

		for i = 1, #Config.dropItems do
			loopedThrough = loopedThrough + Config.dropItems[i].chance

			if itemLottery <= loopedThrough then
				item = Config.dropItems[i]

				break
			end
		end

		if item then
			dropIds = dropIds + 1
			activeDrops[dropIds] = {pickupLocation = math.random(pickupLocations), itemName = item.itemName, label = item.label}

			TriggerClientEvent('d_gunheist:manipulateDrop', -1, dropIds, activeDrops[dropIds])
			TriggerClientEvent('d_gunheist:createBlipOnDrop', src, dropIds, item.label)
			TriggerEvent('d_gunheist:createHeistLoop')
		end
	end
end)

TriggerEvent('d_gunheist:createHeistLoop')

QBCore.Functions.CreateUseableItem('d_hak_kit2', function(source, item) 
    local Player = QBCore.Functions.GetPlayer(source)

	local copsOnDuty = 0
	local _source = source
	local xPlayer = QBCore.Functions.GetPlayer(_source)
	local requiredPolice = 0

	if Config.enablePolice == true then
		requiredPolice = Config.requiredPolice
	end

	for _, v in pairs(QBCore.Functions.GetPlayers()) do
		local Player = QBCore.Functions.GetPlayer(v)
		if Player ~= nil then
			if (Player.PlayerData.job.name == "police" and Player.PlayerData.job.onduty) then
				copsOnDuty = copsOnDuty + 1
			end
		end
	end
	if copsOnDuty >= requiredPolice then
		if Player.Functions.GetItemBySlot(item.slot) ~= nil then
			TriggerClientEvent('d_gunheist:useChip', source)
		end
	else 
		TriggerClientEvent('QBCore:Notify', _source, 'Need at least '..requiredPolice.. ' police to activate the mission.')
	end
  
end)

QBCore.Functions.CreateUseableItem("d_greenchip", function(source, item)
    local Player = QBCore.Functions.GetPlayer(source)
	if Player.Functions.GetItemBySlot(item.slot) ~= nil then
		local itemName = item.name
		TriggerClientEvent('d_gunheist:useDecryptionKey', source,  'd_greenchip')
    end
end)

QBCore.Functions.CreateUseableItem("d_redchip", function(source, item)
    local Player = QBCore.Functions.GetPlayer(source)
	if Player.Functions.GetItemBySlot(item.slot) ~= nil then
		local itemName = item.name
		TriggerClientEvent('d_gunheist:useDecryptionKey', source,  'd_redchip')
    end
end)

QBCore.Functions.CreateUseableItem("d_bluechip", function(source, item)
    local Player = QBCore.Functions.GetPlayer(source)
	if Player.Functions.GetItemBySlot(item.slot) ~= nil then
		local itemName = item.name
		TriggerClientEvent('d_gunheist:useDecryptionKey', source, 'd_bluechip')
    end
end)