--- [ SYSTEM VARIABLES ] ---

local timeSeconds = 0

--- [ SYSTEM THREAD ] ---

Citizen.CreateThread(function()
	while true do
		local timeDistance = 999
		local ped = PlayerPedId()
		if not IsPedInAnyVehicle(ped) then
			local TblImpound = Config['IMPOUND']['START']
			local coords = GetEntityCoords(ped)
			local distance = #(coords - vector3(TblImpound[1],TblImpound[2],TblImpound[3]))
			if distance <= 30 then
				timeDistance = 1
				DrawMarker(23,TblImpound[1],TblImpound[2],TblImpound[3] - 0.95,0.0,0.0,0.0,0.0,0.0,0.0,10.0,10.0,0.0,255,255,255,100,0,0,0,0)

				if IsControlJustPressed(1,38) and timeSeconds <= 0 and distance <= 5 then
					timeSeconds = 2
					ImpoundServer.checkImpound()
				end
			end
		end

		Citizen.Wait(timeDistance)
	end
end)

Citizen.CreateThread(function()
	while true do
		if timeSeconds > 0 then
			timeSeconds = timeSeconds - 1
		end

		Citizen.Wait(1000)
	end
end)