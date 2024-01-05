--- [ CONNECTION ] ---
Tunnel = module("vrp","lib/Tunnel")
Proxy = module("vrp","lib/Proxy")

vRP = Proxy.getInterface("vRP")
vRPC = Tunnel.getInterface("vRP")
Garages = Tunnel.getInterface("vrp_garages")

emitNet = TriggerClientEvent
emit = TriggerEvent
emitItem = emitItem
Permission = vRP.hasPermission


--- [ TUNNEL GET INTERFACE CLIENT ] ---
-- AirforceClient = Tunnel.getInterface('airforce') -- Not used

--- [ TUNNEL GENERATE INTERFACE SERVER ] ---
Airforce = {}
Tunnel.bindInterface('airforce', Airforce)
Dismantle = {}
Tunnel.bindInterface('dismantle', Dismantle)
Drugs = {}
Tunnel.bindInterface('drugs', Drugs)
RobberyNpc = {}
Tunnel.bindInterface('robberynpc', RobberyNpc)
Eletronics = {}
Tunnel.bindInterface('eletronics', Eletronics)
Hunting = {}
Tunnel.bindInterface('hunting', Hunting)
Impound = {}
Tunnel.bindInterface('impound', Impound)
ImpoundProxy = {}
Proxy.addInterface("impound", ImpoundProxy)
Register = {}
Tunnel.bindInterface("register", Register)
Taxi = {}
Tunnel.bindInterface('taxi', Taxi)
TowDriver = {}
Tunnel.bindInterface('towdriver', TowDriver)
Trucker = {}
Tunnel.bindInterface('trucker', Trucker)

--- [ CONNECTION THREAD ] ---
Citizen.CreateThread(function()
  print("[ SYSTEM JOBS ] Waiting Connection")
  Wait(2000)
  print("[ SYSTEM JOBS ] Successfully Loaded and Connection")
end)