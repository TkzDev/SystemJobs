--- [ SYSTEM VARIABLES ] ---
local boxTimers = {}
local playerRobberying = {}


--- [ SYSTEM FUNCTIONS ] ---

local function startBox(boxId,source)
	local TblRegister = Config['REGISTER']
	boxTimers[boxId] = GetGameTimer() + TblRegister['COOLDOWN']['TIME']

	if math.random(100) >= 75 then
		local ped = GetPlayerPed(source)
		local coords = GetEntityCoords(ped)
		local pedId = vRP.getUserId(source)
		emitNet("player:applyGsr",source)

		local policeResult = vRP.getUsersByPermission1("policia.permissao")
		emit('discordLogs','Robberys',"**Jogador:** "..pedId.." \n**Roubo:** Caixa Registradora \n**Data:** "..os.date("%d/%m/%Y %H:%M:%S"))
		for k,v in pairs(policeResult) do
			async(function()
				vRPC.playSound(v,"ATM_WINDOW","HUD_FRONTEND_DEFAULT_SOUNDSET")
				emitNet("NotifyPush",v,{ code = "QRU", title = "Caixa Registradora", x = coords["x"], y = coords["y"], z = coords["z"], criminal = "Alarme de segurança", time = "Recebido às "..os.date("%H:%M"), blipColor = 16 })
			end)
		end
	end
end

function Register.applyTimers(boxId)
	local source = source
	local pedId = vRP.getUserId(source)
	local TblRegister = Config['REGISTER']
	if pedId then
		if boxTimers[boxId] then
			if GetGameTimer() < boxTimers[boxId] then
				emitNet("Notify",source,"amarelo","Sistema indisponível no momento.",5000)
				return false
			else
				local coxinhas = vRP.getUsersByPermission1(TblRegister['POLICEPERMISSION'])
				if #coxinhas < 5 then emitNet("Notify",source,"amarelo","Mínimo de policiais não atingido") return end
				local consultItem = vRP.getInventoryItemAmount(pedId,"pliers") -- ITEM NECESSARIO PARA ROUBO
				if consultItem[1] <= 0 then
					emitNet("Notify",source,"amarelo","Necessário possuir um <b>Alicate</b>.",5000)
					return false
				end

				startBox(boxId,source)
				playerRobberying[pedId] = true
				return true
			end
		else
			playerRobberying[pedId] = true
			startBox(boxId,source)
			return true
		end
	end

	return false
end


function Register.Payment()
	local source = source
	local pedId = vRP.getUserId(source)
	local TblRegister = Config['REGISTER']
	if pedId then
		local random = math.random(TblRegister['PAYMENT']['MIN'],TblRegister['PAYMENT']['MAX'])
		vRP.wantedTimer(pedId,30)
		emitItem(pedId,"reais",random,true)
		emit('discordLogs','Robberys',"**Jogador:** "..pedId.." \n**Roubo:** Caixa Registradora \n**Valor:** "..random.." \n**Data:** "..os.date("%d/%m/%Y %H:%M:%S"))
		playerRobberying[pedId] = nil
	end
end

function Register.clearTable()
	local source = source
	local pedId = vRP.getUserId(source)
	playerRobberying[pedId] = nil
end

function isRobberying(pedId)
	return playerRobberying[pedId]
end

exports('isRobberying', isRobberying)