--- [ SYSTEM VARIABLES ] ---
local userList = {}

--- [ SYSTEM FUNCTIONS ] ---

function TowDriver.enterService()
	local source = source
	local pedId = vRP.getUserId(source)
	if pedId then
		if userList[pedId] == nil then
			userList[pedId] = source
		end
	end

	return true
end

function TowDriver.Payment()
	local source = source
	local pedId = vRP.getUserId(source)
	if pedId then
		local TblTowDriver = Config['TOWDRIVER']
		local random1 = TblTowDriver['PAYMENTLIST'][math.random(#TblTowDriver['PAYMENTLIST'])]
		local random2 =  math.random(40, 80)
		emit("discordLogs", "ReceivedGuincho", "**Jogador:** " .. pedId .. "\n **Item recebido:** " .. random2 .. "x " .. random1 .. "\n**Data:** "..os.date("%d/%m/%Y"))
		emitItem(pedId,random1,random2,true)
	end
end

function TowDriver.tryTow(vehid01,vehid02,mod)
	emitNet("towdriver:syncTow",-1,vehid01,vehid02,tostring(mod))
end


function TowDriver.initServiceG(status)
	local source = source
	local pedId = vRP.getUserId(source)
	if pedId then
		if status then
			vRP.addUserGroup(pedId,"Guincheiro")
		else
			vRP.removeUserGroup(pedId,"Guincheiro")
		end
	end
	return true
end

--- [ SYSTEM EVENTS ] ---

RegisterNetEvent("towdriver:callPlayers")
AddEventHandler("towdriver:callPlayers",function(source,vehName,vehPlate)
	local ped = GetPlayerPed(source)
	local coords = GetEntityCoords(ped)

	for k,v in pairs(userList) do
		async(function()
			emitNet("towdriver:addToList",v,vehPlate)
			emitNet("NotifyPush",v,{ code = "QTH", title = "Registro de Veículo", x = coords["x"], y = coords["y"], z = coords["z"], vehicle = vehicleName(vehName).." - "..vehPlate, time = "Recebido às "..os.date("%H:%M"), blipColor = 33 })
		end)
	end
end)

AddEventHandler('vRP:playerLeave', function(pedId,source)
	if pedId and source then
		if vRP.hasGroup(pedId,"Guincheiro") then
			vRP.removeUserGroup(pedId,"Guincheiro")
		end
	end
end)

AddEventHandler("vRP:playerLeave",function(pedId,source)
	if userList[pedId] then
		userList[pedId] = nil
	end
end)

AddEventHandler('vRP:playerSpawn', function(pedId,source)
	if pedId and source then
		if vRP.hasGroup(pedId,"Guincheiro") then
			vRP.removeUserGroup(pedId,"Guincheiro")
		end
	end
end)