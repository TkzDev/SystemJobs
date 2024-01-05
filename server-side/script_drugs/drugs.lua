--- [ SYSTEM VARIABLES ] ---

local amount = {}
local hasList = {}
local lastTimers = GetGameTimer()

--- [ SYSTEM FUNCTIONS ] ---

function Drugs.GetPermission()
	local source = source
	local pedId = vRP.getUserId(source)
	local TblDrugs = Config['DRUGS']['ACESSPERMISSION']
	if Permission(pedId,TblDrugs) then
		emitNet("Notify",source,"aviso","Sistema indisponível.",5000)
		return false
	end

	return true
end

function Drugs.checkAmount()
	local source = source
	local pedId = vRP.getUserId(source)
	local TblDrugs = Config['DRUGS']
	vCLIENT.printMsg(source, "["..GetCurrentResourceName().."] [server] Started item confirmation.")
	for k,v in pairs(TblDrugs['DRUGSLIST']) do
		local rand = math.random(v["RANDMIN"],v["RANDMAX"])
		local consultItem = vRP.getInventoryItemAmount(pedId,v["ITEM"])
		if consultItem[1] >= parseInt(rand) then
			vCLIENT.printMsg(source, "["..GetCurrentResourceName().."] [server] (SUCCESS) Expected "..rand.." or more "..v["ITEM"]..", received "..consultItem[1]..".")
			local cops = vRP.getUsersByPermission1(TblDrugs['POLICEPERMISSION'])
			local priceMin = v["PRICEMIN"]
			local priceMax = v["PRICEMAX"]
			if (#cops >= 3 and #cops <= 10) then
				priceMin = (v["PRICEMIN"] * 1.2)
				priceMax = (v["PRICEMAX"] * 1.2)
			elseif (#cops >= 11 and #cops <= 25) then
				priceMin = (v["PRICEMIN"] * 1.3)
				priceMax = (v["PRICEMAX"] * 1.3)
			elseif (#cops >= 26) then
				priceMin = (v["PRICEMIN"] * 1.4)
				priceMax = (v["PRICEMAX"] * 1.4)
			end
			amount[pedId] = { v["ITEM"],rand,math.random(priceMin,priceMax) }

			return true
		else 
			vCLIENT.printMsg(source, "["..GetCurrentResourceName().."] [server] (FAILED) Expected "..rand.." or more "..v["ITEM"]..", received "..consultItem[1]..".")
		end
	end
	vCLIENT.printMsg(source, "["..GetCurrentResourceName().."] [server] Finished item confirmation.")

	return false
end

function Drugs.Payment()
	local source = source
	local pedId = vRP.getUserId(source)
	local TblDrugs = Config['DRUGS']
	if vRP.tryGetInventoryItem(pedId,amount[pedId][1],amount[pedId][2],true) then
		vRP.upgradeStress(pedId,2)
		emitNet("player:applyGsr",source)
		local value = amount[pedId][3] * amount[pedId][2]
		if math.random(100) >= 80 then
			local ped = GetPlayerPed(source)
			local coords = GetEntityCoords(ped)
			emitNet("Notify",source,"amarelo","A Polícia foi acionada")
			local policeResult = vRP.getUsersByPermission1(TblDrugs['POLICEPERMISSION'])
			for k,v in pairs(policeResult) do
				async(function()
					emitNet("NotifyPush",v,{ code = "QRU", title = "Venda de Drogas", x = coords["x"], y = coords["y"], z = coords["z"], time = "Recebido às "..os.date("%H:%M"), blipColor = 5 })
				end)
			end
		end
		emitItem(pedId,"reaisz",parseInt(value),true)

		if math.random(100) >= 75 then
			if vRP.tryGetInventoryItem(pedId,"oxy",1,true) then
				emitItem(pedId,"reaisz",math.random(125,175),true)
			end
		end
	end
end

function Drugs.emitCallPolice()
	local source = source
	local pedId = vRP.getUserId(source)
	local ped = GetPlayerPed(source)
	local coords = GetEntityCoords(ped)
	local TblDrugs = Config['DRUGS']
	emitNet("Notify",source,"amarelo","A Polícia foi acionada")
	local policeResult = vRP.getUsersByPermission1(TblDrugs['POLICEPERMISSION'])
	for k,v in pairs(policeResult) do
		async(function()
			emitNet("NotifyPush",v,{ code = "QRU", title = "Venda de Drogas", x = coords["x"], y = coords["y"], z = coords["z"], time = "Recebido às "..os.date("%H:%M"), blipColor = 5 })
		end)
	end
end

function Drugs.insertPedlist(pedId,callPolice,sellDrugs)
	hasList[pedId] = true
	emitNet("drugs:insertList",-1,pedId)

	if GetGameTimer() >= lastTimers then
		lastTimers = GetGameTimer() + (30 * 60000)
		emitNet("drugs:clearList",-1)
	end

	if callPolice then
		if math.random(100) >= 50 then
			local source = source
			local ped = GetPlayerPed(source)
			local coords = GetEntityCoords(ped)
			local textNotify = "Venda de Drogas"

			if not sellDrugs then
				textNotify = "Assalto em Andamento"
			end

			local policeResult = vRP.getUsersByPermission1("policia.permissao")
			for k,v in pairs(policeResult) do
				async(function()
					emitNet("NotifyPush",v,{ code = "QRU", title = textNotify, x = coords["x"], y = coords["y"], z = coords["z"], time = "Recebido às "..os.date("%H:%M"), blipColor = 5 })
				end)
			end
		end
	end
end

--- [ SYSTEM EVENTS ] ---

AddEventHandler("vRP:playerSpawn",function(pedId,source)
	emitNet("drugs:updateList",source,hasList)
end)