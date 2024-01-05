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
	local TblTaxi = Config['TAXI']
	if DoesBlipExist(serviceBlip) then
		RemoveBlip(serviceBlip)
		serviceBlip = nil
	end

	serviceBlip = AddBlipForCoord(TblTaxi['VEHICLESTOP'][selectPosition][1],TblTaxi['VEHICLESTOP'][selectPosition][2],stopVehicle[selectPosition][3])
	SetBlipSprite(serviceBlip,12)
	SetBlipColour(serviceBlip,5)
	SetBlipScale(serviceBlip,0.9)
	SetBlipRoute(serviceBlip,true)
	SetBlipAsShortRange(serviceBlip,true)
	BeginTextCommandSetBlipName("STRING")
	AddTextComponentString("Taxista")
	EndTextCommandSetBlipName(serviceBlip)
end

local function generatePassenger(vehicle)
	local TblTaxi = Config['TAXI']
	if lastPassenger ~= nil then
		emitNetS("tryDeleteObject",lastPassenger)
		lastPassenger = nil
	end

	local randModels = math.random(#TblTaxi['PEDMODELS'])
	local mHash = GetHashKey(TblTaxi['PEDMODELS'][randModels][1])

	RequestModel(mHash)
	while not HasModelLoaded(mHash) do
		Citizen.Wait(1)
	end

	if HasModelLoaded(mHash) then
		currentPassenger = CreatePed(4,TblTaxi['PEDMODELS'][randModels][2],TblTaxi['PEDSPAWN'][selectPosition][1],TblTaxi['PEDSPAWN'][selectPosition][2],TblTaxi['PEDSPAWN'][selectPosition][3],3374176,true,false)
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
				selectPosition = math.random(#TblTaxi['VEHICLESTOP'])
			end
		until lastPosition ~= selectPosition

		currentStatus = true
		blipPassenger()
	end
end



--- [ SYSTEM THREADS ] ---

Citizen.CreateThread(function()
	while true do
		local timeDistance = 999
		local ped = PlayerPedId()
		local TblTaxi = Config['TAXI']
		if not IsPedInAnyVehicle(ped) then
			local coords = GetEntityCoords(ped)
			local distance = #(coords - vector3(TblTaxi['START'][1],TblTaxi['START'][2],TblTaxi['START'][3]))
			if distance <= 2 then
				timeDistance = 1

				if serviceStatus then
					DrawText3D(TblTaxi['START'][1],TblTaxi['START'][2],TblTaxi['START'][3],"~g~E~w~   FINALIZAR")
				else
					DrawText3D(TblTaxi['START'][1],TblTaxi['START'][2],TblTaxi['START'][3],"~g~E~w~   INICIAR")
				end

				if IsControlJustPressed(1,38) then
					if serviceStatus then
						if TaxiServer.initService(false) then
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
						end
					else
						if TaxiServer.initService(true) then
							repeat
								if lastPosition == selectPosition then
									selectPosition = math.random(#TblTaxi['VEHICLESTOP'])
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
			end
		else
			if serviceStatus then
				local coords = GetEntityCoords(ped)
				local vehicle = GetVehiclePedIsUsing(ped)
				local distance = #(coords - vector3(stopVehicle[selectPosition][1],stopVehicle[selectPosition][2],stopVehicle[selectPosition][3]))
				if distance <= 100 then
					timeDistance = 1

					DrawMarker(1,stopVehicle[selectPosition][1],stopVehicle[selectPosition][2],stopVehicle[selectPosition][3] - 3,0,0,0,0,0,0,5.0,5.0,3.0,255,255,255,25,0,0,0,0)
					DrawMarker(21,stopVehicle[selectPosition][1],stopVehicle[selectPosition][2],stopVehicle[selectPosition][3],0,0,0,0,180.0,130.0,1.5,1.5,1.0,255,255,255,100,0,0,0,1)

					if IsControlJustPressed(1,38) and distance <= 2.5 and GetEntityModel(vehicle) == `spintaxi` then
						if currentStatus then
							FreezeEntityPosition(vehicle,true)

							if DoesEntityExist(currentPassenger) then
								TaxiServer.Payment()
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
									selectPosition = math.random(#stopVehicle)
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
