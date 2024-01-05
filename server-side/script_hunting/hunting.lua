--- [ SYSTEM FUNCTIONS ] --- 
function Hunting.checkSwitchblade()
	local source = source
	local pedId = vRP.getUserId(source)
	if pedId then
		if (vRP.inventoryWeight(pedId) + (itemWeight("meatA") * 3)) > vRP.getBackpack(pedId) then
			emitNet("Notify",source,"vermelho","Mochila cheia.",5000)
			return false
		end

		local consultItem = vRP.getInventoryItemAmount(pedId,"switchblade")
		if consultItem[1] >= 1 then
			if vRP.checkBroken(consultItem[2]) then
				emitNet("Notify",source,"vermelho","Item quebrado.",5000)
				return false
			end

			return true
		end
	end

	return false
end

function Hunting.Payment()
	local source = source
	local pedId = vRP.getUserId(source)
	if pedId then
		local reputationValue = vRP.checkReputation(pedId,"hunting")
		if reputationValue <= 500 then
			local randomItens = math.random(100)

			if randomItens <= 70 then
				if math.random(100) <= 75 then
					emitItem(pedId,"meatA",math.random(3),true)
				else
					emitItem(pedId,"meatA",math.random(2),true)
					emitItem(pedId,"meatB",1,true)
				end
			elseif randomItens >= 71 and randomItens <= 90 then
				if math.random(100) <= 75 then
					emitItem(pedId,"meatA",math.random(2),true)
					emitItem(pedId,"meatB",1,true)
				else
					emitItem(pedId,"meatA",1,true)
					emitItem(pedId,"meatB",math.random(2),true)
				end
			else
				if math.random(100) <= 75 then
					emitItem(pedId,"meatB",math.random(2),true)
					emitItem(pedId,"meatC",1,true)
				else
					emitItem(pedId,"meatB",1,true)
					emitItem(pedId,"meatC",math.random(2),true)
				end
			end
		elseif reputationValue >= 501 and reputationValue <= 1000 then
			local randomItens = math.random(100)

			if randomItens <= 70 then
				if math.random(100) <= 75 then
					emitItem(pedId,"meatA",math.random(3),true)

					if math.random(100) <= 50 then
						emitItem(pedId,"meatB",1,true)
					end
				else
					emitItem(pedId,"meatA",math.random(2),true)
					emitItem(pedId,"meatB",1,true)

					if math.random(100) <= 50 then
						emitItem(pedId,"meatC",1,true)
					end
				end
			elseif randomItens >= 71 and randomItens <= 90 then
				if math.random(100) <= 75 then
					emitItem(pedId,"meatA",math.random(2),true)
					emitItem(pedId,"meatB",1,true)

					if math.random(100) <= 50 then
						emitItem(pedId,"meatC",1,true)
					end
				else
					emitItem(pedId,"meatA",1,true)
					emitItem(pedId,"meatB",math.random(2),true)

					if math.random(100) <= 50 then
						emitItem(pedId,"meatS",1,true)
					end
				end
			else
				if math.random(100) <= 75 then
					emitItem(pedId,"meatB",math.random(2),true)
					emitItem(pedId,"meatC",1,true)
				else
					emitItem(pedId,"meatB",1,true)
					emitItem(pedId,"meatC",math.random(2),true)
				end

				if math.random(100) <= 50 then
					emitItem(pedId,"meatS",1,true)
				end
			end
		else
			local randomItens = math.random(100)

			if randomItens <= 70 then
				if math.random(100) <= 75 then
					emitItem(pedId,"meatB",math.random(3),true)

					if math.random(100) <= 50 then
						emitItem(pedId,"meatC",1,true)
					end
				else
					emitItem(pedId,"meatB",math.random(2),true)
					emitItem(pedId,"meatC",1,true)

					if math.random(100) <= 50 then
						emitItem(pedId,"meatS",1,true)
					end
				end
			elseif randomItens >= 71 and randomItens <= 90 then
				if math.random(100) <= 75 then
					emitItem(pedId,"meatB",math.random(2),true)
					emitItem(pedId,"meatC",1,true)
				else
					emitItem(pedId,"meatB",1,true)
					emitItem(pedId,"meatC",math.random(2),true)
				end

				if math.random(100) <= 50 then
					emitItem(pedId,"meatS",1,true)
				end
			else
				if math.random(100) <= 75 then
					emitItem(pedId,"meatC",math.random(2),true)
					emitItem(pedId,"meatS",1,true)
				else
					emitItem(pedId,"meatC",1,true)
					emitItem(pedId,"meatS",math.random(2),true)
				end
			end
		end

		if math.random(1000) <= 10 then
			if (vRP.inventoryWeight(pedId) + itemWeight("horndeer")) <= vRP.getBackpack(pedId) then
				emitItem(pedId,"horndeer",1,true)
			end
		end

		if (vRP.inventoryWeight(pedId) + itemWeight("animalpelt")) <= vRP.getBackpack(pedId) then
			emitItem(pedId,"animalpelt",1,true)
		end

		vRP.insertReputation(pedId,"hunting",1)
		vRP.upgradeStress(pedId,4)
	end
end