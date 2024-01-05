--- [ SYSTEM VARIABLES ] ---

local dismantleATT = {}

--- [ SYSTEM FUNCTIONS ] ---

local function GetDesmanche(pedId)
	local TblDismantle = Config['DISMANTLE']['COOLDOWN']['TYPE']
	for Org,Permission in pairs(TblDismantle) do
		if Permission(pedId,Permission[2]) then
			return Org
		end
	end
	return false
end

local function GetPermission(pedId) 
	local TblDismantle = Config['DISMANTLE']['ACESSPERMISSION']
	for _,Permission in pairs(TblDismantle) do
		if Permission(pedId, Permission) then
			return false
		end
	end
	return true
end

function Dismantle.Payment(vehicle, vehName, vehPlate)
	local source = source
	local pedId = vRP.getUserId(source)
	local TblDismantle = Config['DISMANTLE']['PAYMENTLIST']
	if pedId then
		if GetDesmanche(pedId) == "" then return end
		local value = vehiclePrice(vehName) * 0.1
		if value > 50000 then
			value = 50000
		end
		vRP.upgradeStress(pedId,10)
		Garages.deleteVehicle(source,vehicle)
		dismantleATT[vehName.."-"..vehPlate] = nil
		emitNet("player:applyGsr",source)
		emitItem(pedId,"reaisz",value,true)
		emitItem(pedId,"tyres",math.random(1,2),true)
		emitItem(pedId,TblDismantle[math.random(#TblDismantle)],math.random(35,45),true)
		emitNet("Notify",source,"sucesso","Você recebeu <b>"..parseFormat(value).."</b> e alguns itens em sua mochila por desmanchar o veículo <b>"..vehicleName(vehName).."</b>.")
	end
end

function Dismantle.vehicleAllowed(vehPlate, vehName)
	local source = source
	local pedId = vRP.getUserId(source)
	local TblDismantle = Config['DISMANTLE']
	if pedId then
		if not GetPermission(pedId) then return false end
		local typeDesmanche = GetDesmanche(pedId)
		if cooldown[typeDesmanche] and parseInt(cooldown[typeDesmanche]) > GetGameTimer() then
			local timer = parseInt((cooldown[typeDesmanche] - GetGameTimer()) / 1000)
			emitNet("Notify", source, "amarelo", "Sistema indisponível. Aguarde <b>"..timer.." segundos</b>", 5000)
			return false
		end
		if dismantleATT[vehName.."-"..vehPlate] then
			emitNet("Notify", source, "amarelo", "O veículo já está sendo desmanchado.", 5000)		
			return false
		end
		local plateUser = vRP.userPlate(vehPlate)
		if not plateUser then
			emitNet("Notify", source, "amarelo", "Veículos de paulistas <b>não<b> são aceitos.", 5000)
			return false
		end
		if pedId == tonumber(plateUser) then
			emitNet("Notify", source, "amarelo", "Você <b>não</b> pode desmanchar seu próprio veículo.", 5000)
			return false
		end
		if vIMPOUND.checkImpoundByEntity({vehPlate, vehName}) ~= nil then
			emitNet("Notify", source, "amarelo", "Você <b>não</b> pode desmanchar um veículo registrado.", 5000)
			return false
		end
		local veh = vRP.query("vehicles/selectVehicles",{ pedId = tonumber(plateUser), vehicle = vehName })
		if not veh[1] then
			emitNet("Notify", source, "amarelo", "Veículo <b>não</b> encontrado no banco de dados do DETRAN.", 5000)
				return false
			end
			if veh[1]["arrest"] == 1 or veh[1]["work"] == "true" then
				emitNet("Notify", source, "amarelo", "Veículo <b>protegido</b> pela seguradora.", 5000)
				return false
			end
			cooldown[typeDesmanche] = GetGameTimer() + TblDismantle['COOLDOWN']['TIME']
			dismantleATT[vehName.."-"..vehPlate] = true
			vRP.execute("vehicles/arrestVehicles",{ pedId = parseInt(plateUser), vehicle = vehName, arrest = 1, time = parseInt(os.time()) })
			emit("discordLogs", "Desmanchou", "**Jogador:** "..pedId.." \n**Desmanchou o veículo: "..vehName.." **de** "..tonumber(plateUser).." \n**Data:** "..os.date("%d/%m/%Y %H:%M:%S"))
			local usource = vRP.getUserSource(tonumber(plateUser))
			if usource then
				Citizen.SetTimeout(30000, function()
					emitNet("Notify", usource, "amarelo", "Seu veículo <b>"..vehicleName(vehName).."</b> foi desmanchado.")
				end)
			end
			return true
		end
	end
