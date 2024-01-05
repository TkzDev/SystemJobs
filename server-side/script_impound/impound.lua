--- [ SYSTEM VARIABLES ] ---
local impoundVehs = {}
local plateSave = {}

--- [ SYSTEM FUNCTIONS ] ---

local function runPlate(source,vehPlate)
	local plateUser = vRP.userPlate(vehPlate)
	local TblImpound = Config['IMPOUND']
	if plateUser then
		local identity = vRP.userIdentity(plateUser)
		if identity then
			vRPC.playSound(source,"Event_Message_Purple","GTAO_FM_Events_Soundset")
			emitNet("Notify",source,"default","<b>Passaporte:</b> "..identity["id"].."<br><b>Nome:</b> "..identity["name"].." "..identity["name2"].."<br><b>Nº:</b> "..identity["phone"],10000)
		end
	else
		if not plateSave[vehPlate] then
			plateSave[vehPlate] = { TblImpound['PLATESNAME'][math.random(#TblImpound['PLATESNAME'])].." "..TblImpound['PLATESNAME2'][math.random(#TblImpound['PLATESNAME2'])],vRP.generatePhone() }
		end
		
		vRPC.playSound(source,"Event_Message_Purple","GTAO_FM_Events_Soundset")
		emitNet("Notify",source,"default","<b>Passaporte:</b> 9.999<br><b>Nome:</b> "..plateSave[vehPlate][1].."<br><b>Nº:</b> "..plateSave[vehPlate][2],10000)
	end
end

function ImpoundProxy.checkImpoundByEntity(entity)
	return impoundVehs[entity[2].."-"..entity[1]] or nil
end

function ImpoundProxy.removeImpoundByEntity(entity)
	if impoundVehs[entity[2].."-"..entity[1]] then impoundVehs[entity[2].."-"..entity[1]] = nil end
end

function Impound.checkImpound()
	local source = source
	local pedId = vRP.getUserId(source)
	local TblImpound = Config['IMPOUND']
	if pedId then
		local vehicle,vehNet,vehPlate,vehName = vRPC.vehList(source,7)
		if vehicle then
			if impoundVehs[vehName.."-"..vehPlate] == nil then
				return
			else
				impoundVehs[vehName.."-"..vehPlate] = nil
				emitItem(pedId,TblImpound['PAYMENTLIST'][math.random(#TblImpound['PAYMENTLIST'])],parseInt(math.random(35,45)),true)
				Garages.deleteVehicle(source,vehicle)
			end
		end
	end
end

--- [ SYSTEM EVENTS ] ---

RegisterServerEvent("police:impound")
AddEventHandler("police:impound",function(entity)
	local source = source
	local pedId = vRP.getUserId(source)
	local identity = vRP.getUserIdentity(pedId)
	if pedId and vRP.getHealth(source) > 101 then
		if Permission(pedId,"policia.permissao") then
			local ped = GetPlayerPed(source)
			local coords = GetEntityCoords(ped)
			local res = vRP.prompt(source, "Motivo do registro", "")
			if (not res or res == "") then emitNet("Notify", source, "vermelho", "Motivo do registro inválido") return end
			if impoundVehs[entity[2].."-"..entity[1]] == nil then
				impoundVehs[entity[2].."-"..entity[1]] = true
				emit("towdriver:callPlayers",source,entity[2],entity[1])
				vRPC.playSound(source,"Event_Message_Purple","GTAO_FM_Events_Soundset")
				emitNet("Notify",source,"verde","Veículo <b>"..vehicleName(entity[2]).."</b> foi registrado.",3000)
				emit("discordLogs","Registro","**Policial:** "..identity["name"].." "..identity["name2"].." (#"..pedId..") \n**Registrou o veículo:** "..entity[2].."\n**Do passaporte:** "..parseInt(plateUser).."\n**Com motivo:** "..res.." \n**Data:** "..os.date("%d/%m/%Y %H:%M"))
			else
				emitNet("Notify",source,"amarelo","Veículo <b>"..vehicleName(entity[2]).."</b> já está na lista.",3000)
			end
		end
	end
end)

RegisterServerEvent("police:runPlate")
AddEventHandler("police:runPlate",function(entity)
	local source = source
	local pedId = vRP.getUserId(source)
	if pedId and vRP.getHealth(source) > 101 then
		local TblImpound = Config['IMPOUND']['POLICEPERMISSION']
		if Permission(pedId,TblImpound) then
			runPlate(source,entity[1])
		end
	end
end)

RegisterServerEvent("police:runArrest")
AddEventHandler("police:runArrest",function(entity)
	local source = source
	local pedId = vRP.getUserId(source)
	local identity = vRP.getUserIdentity(pedId)
	local TblImpound = Config['IMPOUND']
	if pedId and vRP.getHealth(source) > 101 then
		if Permission(pedId,TblImpound['POLICEPERMISSION']) then
			local res = vRP.prompt(source, "Motivo da detenção", "")
			if (not res or res == "") then emitNet("Notify", source, "vermelho", "Motivo de detenção inválido") return end
			if vRP.request(source,"Enviar o veículo para detenção com motivo <b>"..res.."</b>?",30) then
				local plateUser = vRP.userPlate(entity[1])
				if plateUser then
					local inVehicle = vRP.query("vehicles/selectVehicles",{ pedId = parseInt(plateUser), vehicle = entity[2] })
					if inVehicle[1] then
						if inVehicle[1]["arrest"] <= 0 then
							vRP.execute("vehicles/arrestVehicles",{ pedId = parseInt(plateUser), vehicle = entity[2], arrest = 1, time = parseInt(os.time()) })
							emitNet("Notify",source,"verde","Veículo apreendido.",5000)
							emit("discordLogs","Detido","**Policial:** "..identity["name"].." "..identity["name2"].." (#"..pedId..") \n**Deteu o veículo:** "..entity[2].."\n**Do passaporte:** "..parseInt(plateUser).."\n**Com motivo:** "..res.." \n**Data:** "..os.date("%d/%m/%Y %H:%M"))
						else
							emitNet("Notify",source,"amarelo","Veículo já se encontra apreendido.",5000)
						end
					end
				end
			end
		end
	end
end)

--- [ SYSTEM COMMANDS ] ---
RegisterCommand("placa",function(source,args,rawCommand)
	local pedId = vRP.getUserId(source)
	local TblImpound = Config['IMPOUND']['POLICEPERMISSION']
	if pedId then
		if Permission(pedId,TblImpound) and args[1] then
			runPlate(source,args[1])
		end
	end
end)