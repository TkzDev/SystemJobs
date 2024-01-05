--- [ SYSTEM VARIABLES ] ---

local lastPosition = 1
local serviceBlip = nil
local selectPosition = 1
local lastPassenger = nil
local currentStatus = false
local serviceStatus = false
local currentPassenger = nil

--- [ SYSTEM FUNCTIONS ] ---


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

local function blipPassenger()
	local TblVehicleStop = Config['AIRFORCE']['VEHICLESTOP']
	if DoesBlipExist(serviceBlip) then
		RemoveBlip(serviceBlip)
		serviceBlip = nil
	end

	serviceBlip = AddBlipForCoord(TblVehicleStop[selectPosition][1],TblVehicleStop[selectPosition][2],TblVehicleStop[selectPosition][3])
	SetBlipSprite(serviceBlip,12)
	SetBlipColour(serviceBlip,5)
	SetBlipScale(serviceBlip,0.9)
	SetBlipRoute(serviceBlip,true)
	SetBlipAsShortRange(serviceBlip,true)
	BeginTextCommandSetBlipName("STRING")
	AddTextComponentString("Passageiro")
	EndTextCommandSetBlipName(serviceBlip)
end

local function generatePassenger(vehicle)
	local TblPedModels = Config['AIRFORCE']['PEDMODELS']
	local TblPedSpawn = Config['AIRFORCE']['PEDSPAWN']
	local TblVehicleStop = Config['AIRFORCE']['VEHICLESTOP']
	if lastPassenger ~= nil then
		emitNetS("tryDeleteObject",lastPassenger)
		lastPassenger = nil
	end

	local randModels = math.random(#TblPedModels)
	local mHash = GetHashKey(TblPedModels[randModels][1])

	RequestModel(mHash)
	while not HasModelLoaded(mHash) do
		Citizen.Wait(1)
	end

	if HasModelLoaded(mHash) then
		currentPassenger = CreatePed(4,TblPedModels[randModels][2],TblPedSpawn[selectPosition][1],TblPedSpawn[selectPosition][2],TblPedSpawn[selectPosition][3],3374176,true,false)
		TaskEnterVehicle(currentPassenger,vehicle,-1,2,1.0,1,0)
		SetEntityAsMissionEntity(currentPassenger,true,true)
		SetEntityInvincible(currentPassenger,true)
		SetModelAsNoLongerNeeded(mHash)

		while true do
			Citizen.Wait(1)

			if IsPedSittingInVehicle(currentPassenger,vehicle) then
				break
			end
		end

		lastPosition = selectPosition
		repeat
			if lastPosition == selectPosition then
				selectPosition = math.random(#TblVehicleStop)
			end
		until lastPosition ~= selectPosition

		currentStatus = true
		blipPassenger()
	end
end

--- [ SYSTEM THREAD ] ---
Citizen.CreateThread(function()
	while true do
		local timeDistance = 999
		local ped = PlayerPedId()
		local TblInit = Config['AIRFORCE']['START']
		local TblVehicleStop = Config['AIRFORCE']['VEHICLESTOP']
		if not IsPedInAnyVehicle(ped) then
			local coords = GetEntityCoords(ped)
			local distance = #(coords - vector3(TblInit[1],TblInit[2],TblInit[3]))
			if distance <= 2 then
				timeDistance = 1

				if serviceStatus then
					DrawText3D(TblInit[1],TblInit[2],TblInit[3],"~g~E~w~   FINALIZAR")
				else
					DrawText3D(TblInit[1],TblInit[2],TblInit[3],"~g~E~w~   INICIAR")
				end

				if IsControlJustPressed(1,38) then
					if serviceStatus then
						serviceStatus = false
						
						if DoesBlipExist(serviceBlip) then
							RemoveBlip(serviceBlip)
							serviceBlip = nil
						end

						if currentPassenger ~= nil then
							emitNetS("tryDeleteObject",PedToNet(currentPassenger))
							currentPassenger = nil
						end

						if lastPassenger ~= nil then
							emitNetS("tryDeleteObject",lastPassenger)
							lastPassenger = nil
						end
					else
						repeat
							if lastPosition == selectPosition then
								selectPosition = math.random(#TblVehicleStop)
								print(selectPosition)
							end
						until lastPosition ~= selectPosition

						currentPassenger = nil
						currentStatus = false
						serviceStatus = true
						lastPassenger = nil
						blipPassenger()
					end
				end
			end
		else
			if serviceStatus then
				local coords = GetEntityCoords(ped)
				local vehicle = GetVehiclePedIsUsing(ped)
				local distance = #(coords - vector3(TblVehicleStop[selectPosition][1],TblVehicleStop[selectPosition][2],TblVehicleStop[selectPosition][3]))
				if distance <= 100 then
					timeDistance = 1

					DrawMarker(1,TblVehicleStop[selectPosition][1],TblVehicleStop[selectPosition][2],TblVehicleStop[selectPosition][3] - 3,0,0,0,0,0,0,5.0,5.0,3.0,255,255,255,25,0,0,0,0)
					DrawMarker(21,TblVehicleStop[selectPosition][1],TblVehicleStop[selectPosition][2],TblVehicleStop[selectPosition][3],0,0,0,0,180.0,130.0,1.5,1.5,1.0,255,255,255,100,0,0,0,1)

					if IsControlJustPressed(1,38) and distance <= 5 then
						if currentStatus then
							FreezeEntityPosition(vehicle,true)

							if DoesEntityExist(currentPassenger) then
								AirforceServer.Payment()
								Citizen.Wait(1000)
								TaskLeaveVehicle(currentPassenger,vehicle,262144)
								TaskWanderStandard(currentPassenger,10.0,10)
								Citizen.Wait(1000)
								SetVehicleDoorShut(vehicle,3,0)
								Citizen.Wait(1000)
							end

							FreezeEntityPosition(vehicle,false)

							lastPassenger = PedToNet(currentPassenger)
							lastPosition = selectPosition
							currentStatus = false

							repeat
								if lastPosition == selectPosition then
									selectPosition = math.random(#TblVehicleStop)
								end
							until lastPosition ~= selectPosition

							blipPassenger()

							SetTimeout(10000,function()
								if lastPassenger ~= nil then
									emitNetS("tryDeleteObject",lastPassenger)
									lastPassenger = nil
								end
							end)
						else
							generatePassenger(vehicle)
						end
					end
				end
			end
		end

		Citizen.Wait(timeDistance)
	end
end)