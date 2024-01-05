--- [ SYSTEM VARIABLES ] ---
local blipHunting = {}
local inHunting = false
local animalHunting = {}

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

local function blipAnimal(i)
	if DoesBlipExist(blipHunting[i]) then
		RemoveBlip(blipHunting[i])
		blipHunting[i] = nil
	end
	
	blipHunting[i] = AddBlipForEntity(animalHunting[i])
	SetBlipSprite(blipHunting[i],141)
	SetBlipColour(blipHunting[i],41)
	SetBlipScale(blipHunting[i],0.8)
	SetBlipAsShortRange(blipHunting[i],true)
	BeginTextCommandSetBlipName("STRING")
	AddTextComponentString("Cervo")
	EndTextCommandSetBlipName(blipHunting[i])
end

local function newHunting(i)
	local TblHunting = Config['HUNTING']
	local rand = math.random(#TblHunting['ANIMALSMODELS'])
	local mHash = GetHashKey(TblHunting['ANIMALSMODELS'][rand])

	RequestModel(mHash)
	while not HasModelLoaded(mHash) do
		Citizen.Wait(1)
	end

	if HasModelLoaded(mHash) then
		local spawnX = math.random(-250,250)
		local spawnY = math.random(-250,250)
		local inLocate = math.random(#TblHunting['ANIMALSPAWN'])

		animalHunting[i] = CreatePed(28,mHash,TblHunting['ANIMALSPAWN'][inLocate][1],TblHunting['ANIMALSPAWN'][inLocate][2],TblHunting['ANIMALSPAWN'][inLocate][3] - 1,false,false,false)
		TaskGoStraightToCoord(animalHunting[i],TblHunting['ANIMALSPAWN'][inLocate][1] + spawnX,TblHunting['ANIMALSPAWN'][inLocate][2] + spawnY,TblHunting['ANIMALSPAWN'][inLocate][3],0.5,-1,0.0,0.0)
		SetPedKeepTask(animalHunting[i],true)
		SetPedCombatMovement(animalHunting[i],3)
		SetPedCombatAbility(animalHunting[i],100)
		SetPedCombatAttributes(animalHunting[i],46,1)

		blipAnimal(i)
	end
end

--- [ SYSTEM THREAD ] ---
	
Citizen.CreateThread(function()
	while true do
		local timeDistance = 999
		local ped = PlayerPedId()
		if not IsPedInAnyVehicle(ped) then
			local coords = GetEntityCoords(ped)
			local TblHunting = Config['HUNTING']['START']
			local distance = #(coords - vector3(TblHunting[1],TblHunting[2],TblHunting[3]))

			if distance <= 2 then
				timeDistance = 1

				if inHunting then
					DrawText3D(TblHunting[1],TblHunting[2],TblHunting[3],"~g~E~w~   FINALIZAR")
				else
					DrawText3D(TblHunting[1],TblHunting[2],TblHunting[3],"~g~E~w~   INICIAR")
				end

				if IsControlJustPressed(1,38) and distance <= 1 then
					for k,v in pairs(blipHunting) do
						if DoesBlipExist(blipHunting[k]) then
							RemoveBlip(blipHunting[k])
							blipHunting[k] = nil
						end
					end

					for k,v in pairs(animalHunting) do
						if DoesEntityExist(animalHunting[k]) then
							DeleteEntity(animalHunting[k])
							animalHunting[k] = nil
						end
					end

					if inHunting then
						inHunting = false
					else
						inHunting = true

						for i = 1,25 do
							newHunting(i)
						end
					end
				end
			end
		end

		Citizen.Wait(timeDistance)
	end
end)


--- [ SYSTEM EVENTS ] ---
RegisterNetEvent("hunting:animalCutting")
AddEventHandler("hunting:animalCutting",function()
	local ped = PlayerPedId()
	if inHunting and animalHunting then
		local coords = GetEntityCoords(ped)
		for k,v in pairs(animalHunting) do
			local deerCoords = GetEntityCoords(animalHunting[k])
			local distance = #(coords - deerCoords)

			if distance <= 1.5 then
				if IsPedDeadOrDying(animalHunting[k]) and not IsPedAPlayer(animalHunting[k]) then
					if HuntingServer.checkSwitchblade() and GetSelectedPedWeapon(ped) == GetHashKey("WEAPON_UNARMED") then
						TaskTurnPedToFaceEntity(ped,animalHunting[k],-1)
						emit("player:blockCommands",true)
						local targetEntity = animalHunting[k]
						emit("cancelando",true)
						animalHunting[k] = nil

						Citizen.Wait(1000)

						vRP.playAnim(true,{"anim@gangops@facility@servers@bodysearch@","player_search"},true)
						vRP.playAnim(false,{"amb@medic@standing@kneel@base","base"},true)

						Citizen.Wait(15000)

						emit("player:blockCommands",false)
						emit("cancelando",false)
						HuntingServer.Payment()
						vRP.removeObjects()

						if DoesBlipExist(blipHunting[k]) then
							RemoveBlip(blipHunting[k])
							blipHunting[k] = nil
						end

						if DoesEntityExist(targetEntity) then
							DeleteEntity(targetEntity)
						end

						newHunting(k)
					end
				end
			end
		end
	end
end)
