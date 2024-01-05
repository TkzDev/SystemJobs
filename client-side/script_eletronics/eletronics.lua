--- [ SYSTEM VARIABLES ] ---
local inTimers = 35
local inService = false
local currentTimer = GetGameTimer()

--- [ SYSTEM THREAD ] ---

Citizen.CreateThread(function()
	local TblEletronics = Config['ELETRONICS']['ATMLOCATIONS']
	for k,v in pairs(TblEletronics) do
		exports["target"]:AddCircleZone("eletronics:"..k,vector3(v[1],v[2],v[3]),0.5,{
			name = "eletronics:"..k,
			heading = v[4]
		},{
			shop = k,
			distance = 1.0,
			options = {
				{
					event = "eletronics:openSystem",
					label = "Roubar",
					tunnel = "shop"
				}
			}
		})
	end
end)

Citizen.CreateThread(function()
	while true do
		local timeDistance = 999
		
		if inService then
			timeDistance = 1
			
			local ped = PlayerPedId()
			if IsControlJustPressed(1,167) or not IsEntityPlayingAnim(ped,"oddjobs@shop_robbery@rob_till","loop",3) then
				emit("player:blockCommands",false)
				emit("cancelando",false)
				emit("Progress",1000)
				vRP.removeObjects()
				EletronicsServer.clearTable()
				inService = false
			end
		end
		
		Citizen.Wait(timeDistance)
	end
end)

--- [ SYSTEM EVENT ] ---

AddEventHandler("eletronics:openSystem",function(eletronicId)
	if EletronicsServer.checkSystems() then
		local TblEletronics = Config['ELETRONICS']['ATMLOCATIONS']
		inTimers = 35
		inService = true
		emit("Progress",36000)
		emit("cancelando",true)
		emit("player:blockCommands",true)
		SetEntityHeading(PlayerPedId(),TblEletronics[eletronicId][4])
		vRP.playAnim(false,{"oddjobs@shop_robbery@rob_till","loop"},true)
		SetEntityCoords(PlayerPedId(),TblEletronics[eletronicId][1],TblEletronics[eletronicId][2],TblEletronics[eletronicId][3] - 1,1,0,0,0)

		while inService do
			if inTimers > 0 and GetGameTimer() >= currentTimer then
				inTimers = inTimers - 1
				EletronicsServer.Payment()
				currentTimer = GetGameTimer() + 1000

				if inTimers <= 0 then
					emit("player:blockCommands",false)
					emit("cancelando",false)
					vRP.removeObjects()
					inService = false
					break
				end
			end

			Citizen.Wait(1)
		end
	end
end)