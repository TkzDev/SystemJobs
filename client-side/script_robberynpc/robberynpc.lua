--- [ SYSTEM VARIABLES ] ---

local actionRobbery = false

--- [ SYSTEM THREAD ] ---
Citizen.CreateThread(function()
	while true do
		local timeDistance = 999
		local ped = PlayerPedId()

		if not actionRobbery then
			if not IsPedInAnyVehicle(ped) and IsPedArmed(ped,6) then
				local aim,target = GetEntityPlayerIsFreeAimingAt(PlayerId())

				if aim and not IsPedAPlayer(target) and GetPedArmour(target) <= 0 and GetPedType(target) ~= 28 then
					if IsPedInAnyVehicle(target) then
						timeDistance = 1

						local coords = GetEntityCoords(ped)
						local vehicle = GetVehiclePedIsUsing(target)
						local speed = GetEntitySpeed(vehicle) * 2.236936
						local plate = string.gsub(GetVehicleNumberPlateText(vehicle), " ", "")
						local distance = #(coords - GetEntityCoords(vehicle))
						local modelName = vRP.vehicleModel(GetEntityModel(vehicle))

						if distance <= 10 and IsPedFacingPed(target,ped,180.0) and speed <= 5 and not hasList[PedToNet(target)] then
							actionRobbery = true

							SetVehicleForwardSpeed(vehicle,0)
							TaskLeaveVehicle(target,vehicle,256)
							SetEntityAsMissionEntity(target,true,true)

							while IsPedInAnyVehicle(target) do
								Citizen.Wait(1)
							end

							Citizen.Wait(250)

							while not NetworkHasControlOfEntity(target) and DoesEntityExist(target) do
								NetworkRequestControlOfEntity(target)
								Citizen.Wait(100)
							end

							TaskSetBlockingOfNonTemporaryEvents(target,true)
							SetBlockingOfNonTemporaryEvents(target,true)
							SetPedDropsWeaponsWhenDead(target,false)
							TaskTurnPedToFaceEntity(target,ped,3.0)
							SetPedSuffersCriticalHits(target,false)
							SetPedAsNoLongerNeeded(target)
							ClearPedTasks(target)

							RequestAnimDict("random@arrests@busted")
							while not HasAnimDictLoaded("random@arrests@busted") do
								Citizen.Wait(1)
							end

							TaskPlayAnim(target,"random@arrests@busted","idle_a",3.0,3.0,-1,49,0,0,0,0)

							local timeAim = 0
							while IsPlayerFreeAiming(PlayerId()) do
								timeAim = timeAim + 1

								local ped = PlayerPedId()
								local coords = GetEntityCoords(ped)
								local distance = #(coords - GetEntityCoords(target))
								if timeAim >= 1000 or IsEntityDead(target) or distance > 10 then
									break
								end

								Citizen.Wait(1)
							end

							if timeAim >= 1000 then
								RequestAnimDict("mp_common")
								while not HasAnimDictLoaded("mp_common") do
									Citizen.Wait(1)
								end

								TaskPlayAnim(target,"mp_common","givetake1_a",3.0,3.0,-1,48,0,0,0,0)
								emitNetS("plateRobberys",plate,modelName)
							end

							ClearPedTasks(target)
							TaskWanderStandard(target,10.0,10)
							TaskReactAndFleePed(target,ped)
							SetPedKeepTask(target,true)

							if math.random(100) >= 75 then
								Citizen.Wait(1000)

								GiveWeaponToPed(target,GetHashKey("WEAPON_PISTOL"),250,true,true)
								TaskShootAtEntity(target,ped,25000,GetHashKey("FIRING_PATTERN_FULL_AUTO"))

								SetTimeout(25000,function()
									ClearPedTasks(target)
									TaskWanderStandard(target,10.0,10)
									TaskReactAndFleePed(target,ped)
									SetPedKeepTask(target,true)
								end)
							end
						end
					else
						timeDistance = 1

						local coords = GetEntityCoords(ped)
						local distance = #(coords - GetEntityCoords(target))

						if distance < 5 and IsPedFacingPed(target,ped,180.0) and not hasList[PedToNet(target)] then
							actionRobbery = true

							if math.random(100) >= 90 then
								DrugsServer.insertPedlist(PedToNet(target),true,false)
							else
								DrugsServer.insertPedlist(PedToNet(target),true,false)
							end

							SetEntityAsMissionEntity(target,true,true)

							while not NetworkHasControlOfEntity(target) and DoesEntityExist(target) do
								NetworkRequestControlOfEntity(target)
								Citizen.Wait(100)
							end

							RequestAnimDict("random@arrests@busted")
							while not HasAnimDictLoaded("random@arrests@busted") do
								Citizen.Wait(1)
							end

							TaskPlayAnim(target,"random@arrests@busted","idle_a",3.0,3.0,-1,49,0,0,0,0)

							TaskSetBlockingOfNonTemporaryEvents(target,true)
							SetBlockingOfNonTemporaryEvents(target,true)
							SetPedDropsWeaponsWhenDead(target,false)
							TaskTurnPedToFaceEntity(target,ped,3.0)
							SetPedSuffersCriticalHits(target,false)
							SetPedAsNoLongerNeeded(target)

							local timeAim = 0
							while IsPlayerFreeAiming(PlayerId()) do
								timeAim = timeAim + 1

								local ped = PlayerPedId()
								local coords = GetEntityCoords(ped)
								local distance = #(coords - GetEntityCoords(target))
								if timeAim >= 1000 or distance > 5 then
									break
								end

								Citizen.Wait(1)
							end

							if timeAim >= 1000 then
								RequestAnimDict("mp_common")
								while not HasAnimDictLoaded("mp_common") do
									Citizen.Wait(1)
								end

								TaskPlayAnim(target,"mp_common","givetake1_a",3.0,3.0,-1,48,0,0,0,0)
								RobberyNpcServer.Payment()
							end

							ClearPedTasks(target)
							TaskWanderStandard(target,10.0,10)
							TaskReactAndFleePed(target,ped)
							SetPedKeepTask(target,true)

							if math.random(100) >= 75 then
								Citizen.Wait(1000)

								GiveWeaponToPed(target,GetHashKey("WEAPON_PISTOL"),255,true,true)
								TaskShootAtEntity(target,ped,25000,GetHashKey("FIRING_PATTERN_FULL_AUTO"))

								SetTimeout(25000,function()
									ClearPedTasks(target)
									TaskWanderStandard(target,10.0,10)
									TaskReactAndFleePed(target,ped)
									SetPedKeepTask(target,true)
								end)
							end
						end
					end

					actionRobbery = false
				end
			end
		end

		Citizen.Wait(timeDistance)
	end
end)