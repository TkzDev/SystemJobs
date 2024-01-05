--- [ SYSTEM FUNCTIONS ] ---

function Airforce.Payment()
	local source = source
	local pedId = vRP.getUserId(source)
	if pedId then
		local randomValue = math.random(Config["AIRFORCE"]["PAYMENT"]["MIN"],Config["AIRFORCE"]["PAYMENT"]["MAX"])
		emitItem(pedId,"reais",randomValue,true)
		emitNet('Notify',source,'Você recebeu '..parseFormat(randomValue * 0.1)..' por trabalhar como '..Config["AIRFORCE"]["NAME"])

		if vRP.isAnyVip(pedId) then
			emitItem(pedId,"reais",randomValue * 0.1,true)
			emitNet('Notify',source,'Você recebeu '..parseFormat(randomValue * 0.1)..' por trabalhar como '..Config["AIRFORCE"]["NAME"]..' sendo VIP.')
		end
	end
end