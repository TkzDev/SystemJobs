--- [ SYSTEM VARIABLES ] ---

local hasList = {}
local hasTimer = 0
local hasStart = false

--- [ SYSTEM COMMANDS ] ---

RegisterCommand("drugs",function()
	if DrugsServer.GetPermission() then
		if hasStart then
			hasStart = false
			emit("Notify","amarelo","Vendas finalizadas.",5000)
		else
			hasStart = true
			emit("Notify","verde","Vendas ativadas.",5000)
		end
	end
end)

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

function Drugs.printMsg(msg)
	print(msg)
	return true
end

--- [ SYSTEM THREAD ] ---
Citizen.CreateThread(function()
	while true do
		local timeDistance = 999
		if hasStart then
			local ped = PlayerPedId()
			if not IsPedInAnyVehicle(ped) and GetEntityHealth(ped) > 101 then
				local coords = GetEntityCoords(ped)
				local _,hasPed = FindFirstPed()

				repeat
					if DoesEntityExist(hasPed) then
						if not IsPedDeadOrDying(hasPed) and GetPedArmour(hasPed) <= 0 and not IsPedAPlayer(hasPed) and not IsPedInAnyVehicle(hasPed) and GetPedType(hasPed) ~= 28 then
							local hasCoords = GetEntityCoords(hasPed)
							local distance = #(coords - hasCoords)

							if distance <= 1.5 and not hasList[PedToNet(hasPed)] then
								timeDistance = 1
								DrawText3D(hasCoords["x"],hasCoords["y"],hasCoords["z"],"~g~E~w~  OFERECER")

								if IsControlJustPressed(1,38) and DrugsServer.checkAmount() then
									if math.random(100) <= 90 then
										print("["..GetCurrentResourceName().."] [client] Setting entity as mission entity.")
										SetEntityAsMissionEntity(hasPed,true,true)

										while not NetworkHasControlOfEntity(hasPed) and DoesEntityExist(hasPed) do
											print("["..GetCurrentResourceName().."] [client] Wait loop while not has control of entity.")
											NetworkRequestControlOfEntity(hasPed)
											Citizen.Wait(100)
										end

										PlayAmbientSpeech1(hasPed,"GENERIC_HI","SPEECH_PARAMS_STANDARD")
										print("["..GetCurrentResourceName().."] [client -> server] Inserting ped to pedList's array. [0]")
										DrugsServer.insertPedlist(PedToNet(hasPed),false,true)
										TaskSetBlockingOfNonTemporaryEvents(hasPed,true)
										SetBlockingOfNonTemporaryEvents(hasPed,true)
										SetPedDropsWeaponsWhenDead(hasPed,false)
										TaskTurnPedToFaceEntity(hasPed,ped,3.0)
										SetPedSuffersCriticalHits(hasPed,false)
										SetPedAsNoLongerNeeded(hasPed)
										hasTimer = 5
										print("["..GetCurrentResourceName().."] [client] Setting time to 10 seconds.")

										while hasTimer >= 0 do
											if not IsPedDeadOrDying(hasPed) and GetEntityHealth(ped) > 101 then
												local coords = GetEntityCoords(ped)
												local hasCoords = GetEntityCoords(hasPed)
												local distance = #(coords - hasCoords)
												if distance <= 2.5 then
													DrawText3D(hasCoords["x"],hasCoords["y"],hasCoords["z"],"~w~AGUARDE  ~g~"..hasTimer.."~w~  SEGUNDOS")
													if hasTimer <= 0 then
														print("["..GetCurrentResourceName().."] [client -> server] (SUCCESS) Sending payment allowed to server.")
														PlayAmbientSpeech1(hasPed,"GENERIC_THANKS","SPEECH_PARAMS_STANDARD")
														TaskWanderStandard(hasPed,10.0,10)
														DrugsServer.Payment()
														hasTimer = -1
														break
													end
												else
													print("["..GetCurrentResourceName().."] [client] (FAILED) Ped refused the sale. [0]")
													PlayAmbientSpeech1(hasPed,"GENERIC_NO","SPEECH_PARAMS_STANDARD")
													TaskWanderStandard(hasPed,10.0,10)
													hasTimer = -1
													break
												end
											else
												print("["..GetCurrentResourceName().."] [client] (FAILED) Ped or player is dead/dying.")
												hasTimer = -1
												break
											end

											Citizen.Wait(1)
										end
										print("["..GetCurrentResourceName().."] [client] End of 'hasTimer' loop.")
									else
										print("["..GetCurrentResourceName().."] [client] (FAILED) Ped refused the sale. [1]")
										PlayAmbientSpeech1(hasPed,"GENERIC_NO","SPEECH_PARAMS_STANDARD")
										print("["..GetCurrentResourceName().."] [client -> server] Inserting ped to pedList's array. [1]")
										DrugsServer.insertPedlist(PedToNet(hasPed),true,true)
										TaskWanderStandard(hasPed,10.0,10)
										TaskReactAndFleePed(hasPed,ped)
										SetPedKeepTask(hasPed,true)

										if math.random(100) >= 90 then
											Citizen.Wait(1000)
											print("["..GetCurrentResourceName().."] [client -> server] Calling police.")
											DrugsServer.callPolice()

											GiveWeaponToPed(hasPed,GetHashKey("WEAPON_PISTOL"),250,true,true)
											TaskShootAtEntity(hasPed,ped,25000,GetHashKey("FIRING_PATTERN_FULL_AUTO"))

											SetTimeout(25000,function()
												ClearPedTasks(hasPed)
												TaskWanderStandard(hasPed,10.0,10)
												TaskReactAndFleePed(hasPed,ped)
												SetPedKeepTask(hasPed,true)
											end)
										end
									end
								end
							end
						end
					end

					searching,hasPed = FindNextPed(_)
				until not searching EndFindPed(_)
			end
		end

		Citizen.Wait(timeDistance)
	end
end)

Citizen.CreateThread(function()
	while true do
		if hasTimer > 0 then
			hasTimer = hasTimer - 1
		end

		Citizen.Wait(1000)
	end
end)

--- [ SYSTEM EVENTS ] ---

RegisterNetEvent("drugs:insertList")
AddEventHandler("drugs:insertList",function(pedId)
	hasList[pedId] = true
end)

RegisterNetEvent("drugs:updateList")
AddEventHandler("drugs:updateList",function(pedTable)
	hasList = pedTable
end)

RegisterNetEvent("drugs:clearList")
AddEventHandler("drugs:clearList",function()
	hasList = {}
end)