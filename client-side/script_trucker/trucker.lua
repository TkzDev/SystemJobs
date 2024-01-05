--- [ SYSTEM VARIABLES ] ---
local inSeconds = 0
local serviceBlip = nil
local initStage = false
local getPackage = false
local deliveryLocates = 1
local packageVehicle = nil


--- [ SYSTEM FUNCTIONS ] --
local function DrawText3D(x,y,z,text)
	local onScreen,_x,_y = GetScreenCoordFromWorldCoord(x,y,z)

	if onScreen then
		BeginTextCommandDisplayText("STRING")
		AddTextComponentSubstringKeyboardDisplay(text)
		SetTextColour(255,255,255,150)
		SetTextScale(0.35,0.35)
		SetTextFont(4)
		SetTextCentre(1)
		EndTextCommandDisplayText(_x,_y)

		local width = string.len(text) / 160 * 0.45
		DrawRect(_x,_y + 0.0125,width,0.03,38,42,56,200)
	end
end

local function makeBlipMarked(x,y,z)
	if DoesBlipExist(serviceBlip) then
		RemoveBlip(serviceBlip)
		serviceBlip = nil
	end

	serviceBlip = AddBlipForCoord(x,y,z)
	SetBlipSprite(serviceBlip,12)
	SetBlipColour(serviceBlip,84)
	SetBlipScale(serviceBlip,0.9)
	SetBlipRoute(serviceBlip,true)
	SetBlipAsShortRange(serviceBlip,true)
	BeginTextCommandSetBlipName("STRING")
	AddTextComponentString("Caminhoneiro")
	EndTextCommandSetBlipName(serviceBlip)
end

--- [ SYSTEM THREAD ] ---
Citizen.CreateThread(function()
	while true do
		local timeDistance = 999
		local ped = PlayerPedId()
		local TblTrucker = Config['TRUCKER']
		if not IsPedInAnyVehicle(ped) then
			local coords = GetEntityCoords(ped)

			if not getPackage then
				local distance = #(coords - vector3(TblTrucker['START'][1],TblTrucker['START'][2],TblTrucker['START'][3]))
				if distance <= 3 then
					timeDistance = 1

					if initStage then
						DrawText3D(TblTrucker['START'][1],TblTrucker['START'][2],TblTrucker['START'][3],"~g~E~w~   RECEBER PAGAMENTO")

						if IsControlJustPressed(1,38) and distance <= 1 and inSeconds <= 0 and GetEntityModel(GetPlayersLastVehicle()) == `actros` then
							TruckerServer.Payment()
							packageVehicle = nil
							initStage = false
							inSeconds = 3

							if DoesBlipExist(serviceBlip) then
								RemoveBlip(serviceBlip)
								serviceBlip = nil
							end
						end
					else
						DrawText3D(TblTrucker['START'][1],TblTrucker['START'][2],TblTrucker['START'][3],"~g~E~w~   INICIAR TRANSPORTE")

						if IsControlJustPressed(1,38) and distance <= 1 and not TruckerServer.checkExist() and inSeconds <= 0 then
							deliveryLocates = math.random(#TblTrucker['DELIVERYLOCATIONS'])
							emit("Notify","amarelo","Dirija-se até seu caminhão <b>Actros</b> e buzine o mesmo<br>e receba a carga responsável pelo transporte.",5000)
							makeBlipMarked(TblTrucker['DELIVERYLOCATIONS'][deliveryLocates][1],TblTrucker['DELIVERYLOCATIONS'][deliveryLocates][2],TblTrucker['DELIVERYLOCATIONS'][deliveryLocates][3])
							getPackage = true
							inSeconds = 3
						end
					end
				end
			else
				local distance = #(coords - vector3(TblTrucker['DELIVERYLOCATIONS'][deliveryLocates][1],TblTrucker['DELIVERYLOCATIONS'][deliveryLocates][2],TblTrucker['DELIVERYLOCATIONS'][deliveryLocates][3]))
				if distance <= 50 then
					timeDistance = 1
					DrawMarker(23,TblTrucker['DELIVERYLOCATIONS'][deliveryLocates][1],TblTrucker['DELIVERYLOCATIONS'][deliveryLocates][2],TblTrucker['DELIVERYLOCATIONS'][deliveryLocates][3] - 0.95,0.0,0.0,0.0,0.0,0.0,0.0,10.0,10.0,0.0,255,255,255,100,0,0,0,0)

					if IsControlJustPressed(1,38) and inSeconds <= 0 and distance <= 5 then
						inSeconds = 3

						local _,vehNet,vehPlate,modelVehicle = vRP.vehList(10)
						if modelVehicle == TblTrucker['DELIVERYLOCATIONS'][deliveryLocates][4] then
							emit("Notify","amarelo","Volte ao ponto de partida e receba o pagamento.",5000)
							emitNetS("garages:deleteVehicle",vehNet,vehPlate)
							makeBlipMarked(TblTrucker['START'][1],TblTrucker['START'][2],TblTrucker['START'][3])
							getPackage = false
							initStage = true
						end
					end
				end
			end
		else
			if getPackage and packageVehicle == nil then
				local coords = GetEntityCoords(ped)
				local distance = #(coords - vector3(TblTrucker['START'][1],TblTrucker['START'][2],TblTrucker['START'][3]))
				if distance <= 50 then
					local veh = GetVehiclePedIsUsing(ped)
					if GetEntityModel(veh) == `actros` then
						timeDistance = 1

						if IsControlJustPressed(1,38) and inSeconds <= 0 then
							inSeconds = 3

							local heading = GetEntityHeading(veh)
							local mHash = GetHashKey(TblTrucker['DELIVERYLOCATIONS'][deliveryLocates][4])
							local vehCoords = GetOffsetFromEntityInWorldCoords(veh,0.0,-12.0,0.0)

							RequestModel(mHash)
							while not HasModelLoaded(mHash) do
								Citizen.Wait(1)
							end

							if HasModelLoaded(mHash) then
								local _,groundZ = GetGroundZAndNormalFor_3dCoord(vehCoords["x"],vehCoords["y"],vehCoords["z"])
								packageVehicle = CreateVehicle(mHash,vehCoords["x"],vehCoords["y"],groundZ,heading,true,false)
								local netveh = NetworkGetNetworkIdFromEntity(packageVehicle)

								NetworkRegisterEntityAsNetworked(packageVehicle)
								while not NetworkGetEntityIsNetworked(packageVehicle) do
									NetworkRegisterEntityAsNetworked(packageVehicle)
									Citizen.Wait(1)
								end
					
								if NetworkDoesNetworkIdExist(netveh) then
									SetEntitySomething(packageVehicle,true)
					
									if NetworkGetEntityIsNetworked(packageVehicle) then
										SetNetworkIdCanMigrate(netveh,true)
										NetworkSetNetworkIdDynamic(netveh,true)
										SetNetworkIdExistsOnAllMachines(netveh,true)
									end
								end
					
								SetNetworkIdSyncToPlayer(netveh,PlayerId(),true)

								SetEntityInvincible(packageVehicle,true)
								SetVehicleOnGroundProperly(packageVehicle)
								SetEntityAsMissionEntity(packageVehicle,true,true)
								SetVehicleHasBeenOwnedByPlayer(packageVehicle,true)
								SetVehicleNeedsToBeHotwired(packageVehicle,false)

								SetModelAsNoLongerNeeded(mHash)
							end
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
		if inSeconds > 0 then
			inSeconds = inSeconds - 1
		end

		Citizen.Wait(1000)
	end
end)
