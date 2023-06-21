## MAKE SURE TO UPDATE ITEMS LISTED BELOW AND THEIR IMAGES AS WELL


--gunheist items
```lua
["d_redchip"] 			 		 = {["name"] = "d_redchip", 					["label"] = "Red key", 			["weight"] = 0, 		["type"] = "item", 		["image"] = "redchip.png", 			["unique"] = false, 	["useable"] = true, 	["shouldClose"] = true,    ["combinable"] = nil,   ["description"] = "Red Decreption key"},
["d_greenchip"] 			 		 = {["name"] = "d_greenchip", 					["label"] = "Green key", 			["weight"] = 0, 		["type"] = "item", 		["image"] = "greenchip.png", 			["unique"] = false, 	["useable"] = true, 	["shouldClose"] = true,    ["combinable"] = nil,   ["description"] = "Green Decreption key"},
["d_bluechip"] 			 		 = {["name"] = "d_bluechip", 					["label"] = "Blue key", 			["weight"] = 0, 		["type"] = "item", 		["image"] = "bluechip.png", 			["unique"] = false, 	["useable"] = true, 	["shouldClose"] = true,    ["combinable"] = nil,   ["description"] = "Blue Decreption key"},
["d_hak_kit2"] 			 		 = {["name"] = "d_hak_kit2", 					["label"] = "Hacking Drive", 			["weight"] = 0, 		["type"] = "item", 		["image"] = "hak_kit2.png", 			["unique"] = false, 	["useable"] = true, 	["shouldClose"] = true,    ["combinable"] = nil,   ["description"] = "Hacking Usb Drive"},
['drill_gh'] 			 		 = {['name'] = 'drill_gh', 			    		['label'] = 'Gun Heist Drill', 			['weight'] = 10000, 	['type'] = 'item', 		['image'] = 'drill_gh.png', 				['unique'] = false, 	['useable'] = false, 	['shouldClose'] = false,   ['combinable'] = nil,   ['description'] = 'The real deal to get stuff...'},
```

## ps-dispatch > server > sv_dispatchcodes.lua
```lua
	["guncraterobbery"] =  {displayCode = '10-90', description = "Gun Crate Robbery In Progress", radius = 0, recipientList = {'police'}, blipSprite = 478, blipColour = 4, blipScale = 1.5, blipLength = 2, sound = "Lose_1st", sound2 = "GTAO_FM_Events_Soundset", offset = "false", blipflash = "false"},
```

## ps-dispatch > client > cl_events.lua
```lua
-- Gun Crate Robbery
local function gunCreateRobbery(camId)
    local currentPos = GetEntityCoords(PlayerPedId())
    local locationInfo = getStreetandZone(currentPos)
    local gender = GetPedGender()
    TriggerServerEvent("dispatch:server:notify", {
        dispatchcodename = "guncraterobbery", -- has to match the codes in sv_dispatchcodes.lua so that it generates the right blip
        dispatchCode = "10-90",
        firstStreet = locationInfo,
        gender = gender,
        camId = camId,
        model = nil,
        plate = nil,
        priority = 2, -- priority
        firstColor = nil,
        automaticGunfire = false,
        origin = {
            x = currentPos.x,
            y = currentPos.y,
            z = currentPos.z
        },
        dispatchMessage = ('Gun Crate Robbery'), -- message
        job = { "police" } -- jobs that will get the alerts
    })
end

exports('gunCreateRobbery', gunCreateRobbery)
```
