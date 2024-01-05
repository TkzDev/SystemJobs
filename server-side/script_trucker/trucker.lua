--- [ SYSTEM VARIABLES ] ---
local deliveryPackage = {}

--- [ SYSTEM FUNCTIONS ] ---
function Trucker.checkExist()
	return false
end

function Trucker.Payment()
	local source = source
	local pedId = vRP.getUserId(source)
	if pedId then
		local TblTrucker = Config['TRUCKER']
		local coords = GetEntityCoords(GetPlayerPed(source))
		local distance = #(vec3(coords[1], coords[2], coords[3]) - vec3(TblTrucker['DELIVERYPOINT'][1], TblTrucker['DELIVERYPOINT'][2], TblTrucker['DELIVERYPOINT'][3]))
		if distance < 12.0 then
			if deliveryPackage[pedId] == nil then
				deliveryPackage[pedId] = 0
			end

			emitItem(pedId,"reais",math.random(TblTrucker['PAYMENT']['MIN'],TblTrucker['PAYMENT']['MAX']),true)

			deliveryPackage[pedId] = deliveryPackage[pedId] + 1
		end
	end
end