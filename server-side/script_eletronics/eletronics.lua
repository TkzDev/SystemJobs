--- [ SYSTEM VARIABLES ] ---
local atmTimers = GetGameTimer()
local playerRobberying = {}

--- [ SYSTEM FUNCTIONS ] ---

local function isRobberying(pedId)
	if playerRobberying[pedId] then
		return true
	else
		return false
	end
end

--- [ SYSTEM FUNCTIONS ] ---

function Eletronics.checkSystems()
	local source = source
	local pedId = vRP.getUserId(source)
	local TblEletronics = Config['ELETRONICS']
	if pedId then
		local policeResult = vRP.getUsersByPermission1(TblEletronics['POLICEPERMISSION'])
		if parseInt(#policeResult) <= 6 or GetGameTimer() < atmTimers then
			local timer = parseInt((atmTimers - GetGameTimer()) / 1000)
			emitNet("Notify",source,"amarelo","Sistema indisponível no momento. Aguarde <b>"..timer.." segundos</b>",5000)
			return false
		else
			local consultItem = vRP.getInventoryItemAmount(pedId,"floppy") -- item para iniciar o roubo
			if consultItem[1] <= 0 then
				emitNet("Notify",source,"amarelo","Necessário possuir um <b>Disquete</b>.",5000)
				return false
			end

			local ped = GetPlayerPed(source)
			local coords = GetEntityCoords(ped)
			atmTimers = GetGameTimer() + TblEletronics['COOLDOWN']['TIME']
			emitNet("player:applyGsr",source)
			emit('discordLogs','Robberys',"**Jogador:** "..pedId.." \n**Roubo:** Caixa Eletrônico \n**Data:** "..os.date("%d/%m/%Y %H:%M:%S"))
			for k,v in pairs(policeResult) do
				async(function()
					vRPC.playSound(v,"ATM_WINDOW","HUD_FRONTEND_DEFAULT_SOUNDSET")
					emitNet("NotifyPush",v,{ code = "QRU", title = "Caixa Eletrônico", x = coords["x"], y = coords["y"], z = coords["z"], criminal = "Alarme de segurança", time = "Recebido às "..os.date("%H:%M"), blipColor = 16 })
				end)
			end
			playerRobberying[pedId] = 36
			return true
		end
	end

	return false
end

function Eletronics.Payment()
	local source = source
	local pedId = vRP.getUserId(source)
	local TblEletronics = Config['ELETRONICS']['PAYMENT']
	if pedId then
		if playerRobberying[pedId] and playerRobberying[pedId] > 0 then
			vRP.wantedTimer(pedId,8)
			local random = math.random(TblEletronics['MIN'],TblEletronics['MAX'])
			emitItem(pedId,"reaisz",random)
			emit('discordLogs','Robberys',"**Jogador:** "..pedId.." \n**Roubo:** Caixa Eletrônico \n**Valor:** "..random.." \n**Data:** "..os.date("%d/%m/%Y %H:%M:%S"))
			playerRobberying[pedId] = playerRobberying[pedId] - 1
			if playerRobberying[pedId] <= 0 then
				playerRobberying[pedId] = nil -- clearing user table (performance)
			end
		end
	end
end

function Eletronics.clearTable()
	local source = source
	local pedId = vRP.getUserId(source)
	playerRobberying[pedId] = nil
end

exports("isRobberying", isRobberying)