--- [ CONNECTION ] ---

Tunnel = module("vrp", "lib/Tunnel")
Proxy = module("vrp", "lib/Proxy")

vRP = Proxy.getInterface('vRP')
vRPS = Tunnel.getInterface('vRP')

emitNetS = TriggerServerEvent
emit = TriggerEvent


--- [ TUNNEL GET INTERFACE SERVER ] ---
AirforceServer = Tunnel.getInterface('airforce')
DismantleServer = Tunnel.getInterface('dismantle')
DrugsServer = Tunnel.getInterface('drugs')
RobberyNpcServer = Tunnel.getInterface('robberynpc')
EletronicsServer = Tunnel.getInterface('eletronics')
HuntingServer = Tunnel.getInterface('hunting')
ImpoundServer = Tunnel.getInterface('impound')
RegisterServer = Tunnel.getInterface('register')
TaxiServer = Tunnel.getInterface('taxi')
TowDriverServer = Tunnel.getInterface('towdriver')
TruckerServer = Tunnel.getInterface('trucker')

--- [ TUNNEL GENERATE INTERFACE CLIENT ] ---
Airforce = {}
Tunnel.bindInterface('airforce', airforce)