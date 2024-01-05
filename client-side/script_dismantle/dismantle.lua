--- [ SYSTEM VARIABLES ] ---

local dismantleProgress = false

local vehDoors = {
	{ "handle_dside_f",0 },
	{ "handle_pside_f",1 },
	{ "handle_dside_r",2 },
	{ "handle_pside_r",3 }
}

local vehTyres = {
	{ "wheel_lf",0 },
	{ "wheel_rf",1 },
	{ "wheel_lr",4 },
	{ "wheel_rr",5 }
}

--- [ SYSTEM EVENTS ] ---

RegisterNetEvent("dismantle:checkVehicle")
AddEventHandler("dismantle:checkVehicle",function(vehicle)
	if not dismantleProgress then
		local pedId = PlayerPedId()
		local vehName = vRP.vehicleModel(vehicle[2])
		local vehPlate = string.gsub(GetVehicleNumberPlateText(vehicle[1]), " ", "")

		if DismantleServer.vehicleAllowed(vehPlate,vehName) then
			dismantleProgress = true

			SetEntityInvincible(pedId,true)
			FreezeEntityPosition(pedId,true)
			emit("cancelando",true)
			FreezeEntityPosition(vehicle[1],true)
			vRP.playAnim(false,{Config['DISMANTLE']['ANIMATION']['ANIM'], Config['DISMANTLE']['ANIMATION']['DICT']},true)

			for _,v in pairs(vehDoors) do
				local objectExist = GetEntityBoneIndexByName(vehicle[1],v[1])
				if objectExist ~= -1 then
					Citizen.Wait(10000)
					SetVehicleDoorBroken(vehicle[1],v[2],false)
				end
			end

			for _,v in pairs(vehTyres) do
				local objectExist = GetEntityBoneIndexByName(vehicle[1],v[1])
				if objectExist ~= -1 then
					Citizen.Wait(10000)
					SetVehicleTyreBurst(vehicle[1],v[2],1,1000.01)
				end
			end

			vRP.removeObjects()
			SetEntityInvincible(pedId,false)
			FreezeEntityPosition(pedId,false)
			emit("cancelando",false)
			DismantleServer.Payment(vehicle[1], vehName, vehPlate)

			dismantleProgress = false
		end
	end
end)