--- [ SYSTEM THREAD ] ---

Citizen.CreateThread(function()
	local TblRegister = Config['REGISTER']['REGISTERLOCATIONS']
	for k,v in pairs(TblRegister) do
		exports["target"]:AddCircleZone("register:"..k,vector3(v[1],v[2],v[3]),1.0,{
			name = "register:"..k,
			heading = v[4]
		},{
			shop = k,
			distance = 1.0,
			options = {
				{
					event = "register:openSystem",
					label = "Roubar",
					tunnel = "shop"
				}
			}
		})
	end
end)

--- [ SYSTEM EVENT ] ---

AddEventHandler("register:openSystem",function(registerId)
	if RegisterServer.applyTimers(registerId) then
		local TblRegister = Config['REGISTER']['REGISTERLOCATIONS']
		SetEntityHeading(ped,TblRegister[registerId][4])
		SetEntityCoords(ped,TblRegister[registerId][1],TblRegister[registerId][2],TblRegister[registerId][3] - 1,1,0,0,0)
		local safeCracking = exports["safecrack"]:safeCraking(1)
		if safeCracking then
			RegisterServer.Payment()
		else
			RegisterServer.clearTable()
		end
	end
end)