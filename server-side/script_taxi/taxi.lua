--- [ SYSTEM FUNCTIONS ] ---
function Taxi.Payment()
	local source = source
	local pedId = vRP.getUserId(source)
	local aceito = false
	local player_cds = GetEntityCoords(GetPlayerPed(source))
	local TblTaxi = Config['TAXI']
	if pedId then
		if vRP.hasGroup(pedId, "Taxi") then
			for _,v in pairs(TblTaxi['VEHICLESTOP']) do
				local distance = #(vec3(player_cds[1], player_cds[2], player_cds[3]) - vec3(v[1], v[2], v[3]))
				if distance < 12.0 then
					aceito = true
				end
			end
			if aceito then
				local value = math.random(TblTaxi['PAYMENT']['MIN'],TblTaxi['PAYMENT']['MAX'])
				emitItem(pedId,"reais",value,true)

				if vRP.isAnyVip(pedId) then
					emitItem(pedId,"reais",value * 0.1,true)
				end
			end
		end
	end
end

function Taxi.initService(status)
	local source = source
	local pedId = vRP.getUserId(source)
	if pedId then
		if status then
			vRP.addUserGroup(pedId,"Taxi")
		else
			vRP.removeUserGroup(pedId,"Taxi")
		end
	end
	return true
end


---[ SYSTEM EVENTS ]---

AddEventHandler('vRP:playerLeave', function(pedId,source)
	if pedId and source then
		if vRP.hasGroup(pedId,"Taxi") then
			vRP.removeUserGroup(pedId,"Taxi")
		end
	end
end)

AddEventHandler('vRP:playerSpawn', function(pedId,source)
	if pedId and source then
		if vRP.hasGroup(pedId,"Taxi") then
			vRP.removeUserGroup(pedId,"Taxi")
		end
	end
end)