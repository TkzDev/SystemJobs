--- [ SYSTEM FUNCTIONS ] ---
function RobberyNpc.paymentRobbery()
	local source = source
	local pedId = vRP.getUserId(source)
  local TblRobbery = Config['DRUGS']['ROBBERYNPC']
  local rand = math.random(#TblRobbery)
  local value = math.random(TblRobbery[rand]["MIN"],TblRobbery[rand]["MAX"])

  emitItem(pedId,TblRobbery[rand]["ITEM"],value,true)
end

