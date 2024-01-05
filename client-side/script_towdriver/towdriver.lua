--- [ SYSTEM VARIABLES ] ---

local inTowed = nil
local vehTower = nil
local vehicleNet = 0
local spawnSelect = 0
local spawnCoords = 0
local inService = false
local serviceLocate = 1
local timeSeconds = GetGameTimer()
local list = {}

--- [ SYSTEM THREAD ] ---

Citizen.CreateThread(function()
	while true do
		local timeDistance = 999
		local ped = PlayerPedId()
		local TblTowDriver = Config['TOWDRIVER']
		if not IsPedInAnyVehicle(ped) then
			local coords = GetEntityCoords(ped)

			local distance = #(coords - vector3(TblTowDriver['START'][1],TblTowDriver['START'][2],TblTowDriver['START'][3]))

			if distance <= 15 then
				timeDistance = 1
				DrawMarker(23,TblTowDriver['START'][1],TblTowDriver['START'][2],TblTowDriver['START'][3] - 0.95,0.0,0.0,0.0,0.0,0.0,0.0,1.0,1.0,0.0,255,255,255,100,0,0,0,0)

				if distance <= 0.5 and IsControlJustPressed(1,38) and TowDriverServer.enterService() then
					if inService then
						if TowDriverServer.initServiceG(false) then
							inService = false
						end
					else
						if TowDriverServer.initServiceG(true) then
							inService = true
							serviceLocate = k
							spawnSelect = parseInt(math.random(#TblTowDriver['VEHICLESMODELS']))
							spawnCoords = parseInt(math.random(#TblTowDriver['VEHICLEPARKING'][serviceLocate]))
							
							emit("NotifyPush",{ code = "QTH", title = "Registro de Veículo", x = TblTowDriver['VEHICLEPARKING'][serviceLocate][spawnCoords][1], y = TblTowDriver['VEHICLEPARKING'][serviceLocate][spawnCoords][2], z = TblTowDriver['VEHICLEPARKING'][serviceLocate][spawnCoords][3], name = "Aguardando reboque.", blipColor = 2 })
						end
					end
				end
			end
		end

		Citizen.Wait(timeDistance)
	end
end)

Citizen.CreateThread(function()
	while true do
		if inService then
			local ped = PlayerPedId()
			local coords = GetEntityCoords(ped)
			local TblTowDriver = Config['TOWDRIVER']
			local distance = #(coords - vector3(TblTowDriver['VEHICLEPARKING'][serviceLocate][spawnCoords][1],TblTowDriver['VEHICLEPARKING'][serviceLocate][spawnCoords][2],TblTowDriver['VEHICLEPARKING'][serviceLocate][spawnCoords][3]))

			if distance <= 100 and vehicleNet == 0 then
				local mHash = GetHashKey(TblTowDriver['VEHICLESMODELS'][spawnSelect][1])

				RequestModel(mHash)
				while not HasModelLoaded(mHash) do
					Citizen.Wait(1)
				end

				if HasModelLoaded(mHash) then
					local _,groundZ = GetGroundZAndNormalFor_3dCoord(TblTowDriver['VEHICLEPARKING'][serviceLocate][spawnCoords][1],TblTowDriver['VEHICLEPARKING'][serviceLocate][spawnCoords][2],TblTowDriver['VEHICLEPARKING'][serviceLocate][spawnCoords][3])
					local nveh = CreateVehicle(mHash,TblTowDriver['VEHICLEPARKING'][serviceLocate][spawnCoords][1],TblTowDriver['VEHICLEPARKING'][serviceLocate][spawnCoords][2],groundZ,TblTowDriver['VEHICLEPARKING'][serviceLocate][spawnCoords][4],true,false)
					local netveh = NetworkGetNetworkIdFromEntity(nveh)

					NetworkRegisterEntityAsNetworked(nveh)
					while not NetworkGetEntityIsNetworked(nveh) do
						NetworkRegisterEntityAsNetworked(nveh)
						Citizen.Wait(1)
					end

					if NetworkDoesNetworkIdExist(netveh) then
						SetEntitySomething(nveh,true)

						if NetworkGetEntityIsNetworked(nveh) then
							SetNetworkIdCanMigrate(netveh,true)
							NetworkSetNetworkIdDynamic(netveh,true)
							SetNetworkIdExistsOnAllMachines(netveh,true)
						end
					end

					SetNetworkIdSyncToPlayer(netveh,PlayerId(),true)

					SetEntityInvincible(nveh,true)
					SetVehicleOnGroundProperly(nveh)
					SetEntityAsMissionEntity(nveh,true,true)
					SetVehicleHasBeenOwnedByPlayer(nveh,true)
					SetVehicleNeedsToBeHotwired(nveh,false)

					SetVehicleEngineHealth(nveh,100.0)
					SetVehicleBodyHealth(nveh,100.0)
					SetVehicleFuelLevel(nveh,0.0)

					SetModelAsNoLongerNeeded(mHash)

					vehicleNet = nveh
				end
			end
		end

		Citizen.Wait(1000)
	end
end)

Citizen.CreateThread(function()
	while true do
		local timeDistance = 999
		if inService then
			local ped = PlayerPedId()
			local coords = GetEntityCoords(ped)
			local TblTowDriver = Config['TOWDRIVER']
			local distance = #(coords - vector3(TblTowDriver['TOWEDVEHICLE'][serviceLocate][1],TblTowDriver['TOWEDVEHICLE'][serviceLocate][2],TblTowDriver['TOWEDVEHICLE'][serviceLocate][3]))
			if distance <= 30 then
				timeDistance = 1
				DrawMarker(23,TblTowDriver['TOWEDVEHICLE'][serviceLocate][1],TblTowDriver['TOWEDVEHICLE'][serviceLocate][2],TblTowDriver['TOWEDVEHICLE'][serviceLocate][3] - 0.95,0.0,0.0,0.0,0.0,0.0,0.0,10.0,10.0,0.0,255,255,255,100,0,0,0,0)

				if IsControlJustPressed(1,38) and not IsPedInAnyVehicle(ped) and GetGameTimer() >= timeSeconds and distance <= 5 and vehTower == nil then
					timeSeconds = GetGameTimer() + 1000

					local vehicle,vehNet,vehPlate,vehName = vRP.vehList(7)
					if IsEntityAVehicle(vehicle) then
						if (vehName == TblTowDriver['VEHICLESMODELS'][spawnSelect][1]) or list[vehPlate] then
							TowDriverServer.Payment()
							emit("towdriver:removeFromList",vehPlate)
							vehicleNet = 0
							spawnSelect = parseInt(math.random(#TblTowDriver['VEHICLESMODELS']))
							spawnCoords = parseInt(math.random(#TblTowDriver['VEHICLEPARKING'][serviceLocate]))

							emitNetS("garages:deleteVehicle",vehNet,vehPlate)

							emit("NotifyPush",{ code = "QTH", title = "Registro de Veículo", x = TblTowDriver['VEHICLEPARKING'][serviceLocate][spawnCoords][1], y = TblTowDriver['VEHICLEPARKING'][serviceLocate][spawnCoords][2], z = TblTowDriver['VEHICLEPARKING'][serviceLocate][spawnCoords][3], name = "Aguardando reboque.", blipColor = 2 })
						end
					end
				end
			end
		end

		Citizen.Wait(timeDistance)
	end
end)

--- [ SYSTEM EVENT ] ---

RegisterNetEvent("towdriver:invokeTow")
AddEventHandler("towdriver:invokeTow",function()
	local ped = PlayerPedId()
	local vehicle = GetLastDrivenVehicle()
	if IsVehicleModel(vehicle,GetHashKey("flatbed")) and not IsPedInAnyVehicle(ped) then
		local vehTowed = vRP.nearVehicle(10)

		if DoesEntityExist(vehicle) and DoesEntityExist(vehTowed) then
			local vehCoords01 = GetEntityCoords(vehicle)
			local vehCoords02 = GetEntityCoords(vehTowed)
			local vehDistance = #(vehCoords01 - vehCoords02)

			if vehDistance <= 10 then
				if inTowed then
					TowDriverServer.tryTow(NetworkGetNetworkIdFromEntity(vehicle),NetworkGetNetworkIdFromEntity(inTowed),"out")
					vehTower = nil
					inTowed = nil
				else
					if vehicle ~= vehTowed then
						RequestAnimDict("mini@repair")
						while not HasAnimDictLoaded("mini@repair") do
							Citizen.Wait(1)
						end

						vehTower = vehTowed
						emit("cancelando",true)
						emit("sounds:source","tow",0.5)
						emit("player:blockCommands",true)
						TaskTurnPedToFaceEntity(ped,vehTowed,5000)
						TaskPlayAnim(ped,"mini@repair","fixing_a_player",3.0,3.0,-1,50,0,0,0,0)

						Citizen.Wait(4500)

						inTowed = vehTowed
						emit("cancelando",false)
						emit("player:blockCommands",false)
						StopAnimTask(ped,"mini@repair","fixing_a_player",2.0)
						TowDriverServer.tryTow(NetworkGetNetworkIdFromEntity(vehicle),NetworkGetNetworkIdFromEntity(vehTowed),"in")
					end
				end
			else
				emit("Notify","amarelo","Reboque precisa estar próximo do veículo.",3000)
			end
		end
	end
end)

RegisterNetEvent("towdriver:syncTow")
AddEventHandler("towdriver:syncTow",function(vehid01,vehid02,mod)
	if NetworkDoesNetworkIdExist(vehid01) and NetworkDoesNetworkIdExist(vehid02) then
		local vehicle = NetToEnt(vehid01)
		local vehTowed = NetToEnt(vehid02)
		if DoesEntityExist(vehicle) and DoesEntityExist(vehTowed) then
			if mod == "in" then
				local min,max = GetModelDimensions(GetEntityModel(vehTowed))
				AttachEntityToEntity(vehTowed,vehicle,GetEntityBoneIndexByName(vehicle,"bodyshell"),0,-2.2,0.4 - min["z"],0,0,0,1,1,0,1,0,1)
			elseif mod == "out" then
				DetachEntity(vehTowed,false,false)

				local vehHeading = GetEntityHeading(vehicle)
				local vehCoords = GetOffsetFromEntityInWorldCoords(vehicle,0.0,-10.0,0.0)
				SetEntityCoords(vehTowed,vehCoords["x"],vehCoords["y"],vehCoords["z"],1,0,0,0)
				SetEntityHeading(vehTowed,vehHeading)
				SetVehicleOnGroundProperly(vehTowed)
			end
		end
	end
end)

RegisterNetEvent("towdriver:addToList",function(vehPlate)
	if not list then
		list = {}
	end
	list[vehPlate] = true
end)

AddEventHandler("towdriver:removeFromlist",function(vehPlate)
	if list[vehPlate] then
		list[vehPlate] = nil
	end
end)