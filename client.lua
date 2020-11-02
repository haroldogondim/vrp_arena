-----------------------------------------------------------------------------------------------------------------------------------------
-- Script desenvolvido por Kisha. Email: slentkat@gmail.com / GitHub: https://github.com/haroldogondim
-----------------------------------------------------------------------------------------------------------------------------------------
-- VRP
-----------------------------------------------------------------------------------------------------------------------------------------
local Tunnel = module("vrp","lib/Tunnel")
local Proxy = module("vrp","lib/Proxy")
vRP = Proxy.getInterface("vRP")
-----------------------------------------------------------------------------------------------------------------------------------------
-- CONEXÃO
-----------------------------------------------------------------------------------------------------------------------------------------
src = {}
Tunnel.bindInterface("vrp_arena",src)
kSERVER = Tunnel.getInterface("vrp_arena")
-----------------------------------------------------------------------------------------------------------------------------------------
-- VARIAVEIS
-----------------------------------------------------------------------------------------------------------------------------------------
local searchProgress = false
local isDominating = false
local dominatingPerms = {}
local hasPermName = ""

Citizen.CreateThread(function()
	while true do
		if isDominating ~= kSERVER.isDominating() then
			isDominating = kSERVER.isDominating()
			if isDominating then
				dominatingPerms = kSERVER.dominatingNow()
				hasPermName = ""
				for kx, vx in pairs(kSERVER.dominatingNow()) do
					if kSERVER.checkPermission(vx) then
						hasPermName = vx
					end
				end
			else
				hasPermName = ""
				dominatingPerms = {}
			end
		end
		Citizen.Wait(1000)
	end
end)

-----------------------------------------------------------------------------------------------------------------------------------------
-- COORDENADAS DOS BLIPS
-----------------------------------------------------------------------------------------------------------------------------------------
local coordenadas_perms_blips = {
	['bratva.permissao'] = {
		[1] = { ['x'] = 1423.34, ['y'] = 3187.47, ['z'] = 40.48 },
		[2] = { ['x'] = 1426.78, ['y'] = 3188.08, ['z'] = 40.48 }
	},
	['motoclub.permissao'] = {
		[1] = { ['x'] = 1430.52, ['y'] = 3185.11, ['z'] = 40.44 },
	},
	['municao.permissao'] = {
		[1] = { ['x'] = 1436.35, ['y'] = 3176.97, ['z'] = 40.42 },
	},
	['mcnorte.permissao'] = {
		[1] = { ['x'] = 1439.96, ['y'] = 3172.21, ['z'] = 40.43 },
	},
}

Citizen.CreateThread(function()
	while true do
		local kswait = 500
		if isDominating and hasPermName ~= "" then
			for k_d,v_d in pairs(dominatingPerms) do
				if hasPermName == v_d then
					local ped = PlayerPedId()
					local x,y,z = table.unpack(GetEntityCoords(ped))
					for k,v in pairs(coordenadas_perms_blips[v_d]) do
						local distance = Vdist(x,y,z,v.x,v.y,v.z)
						if distance <= 15 then
							kswait = 2
							DrawMarker(2,v.x,v.y,v.z-0.2,0,0,0,0.0,0,0,0.3,0.3,0.4,99,47,121,100,1,0,0,1)
							if distance <= 1.8 then 
								drawTxt("PRESSIONE  ~g~E~w~  PARA VASCULHAR O LOCAL",4,0.5,0.93,0.50,255,255,255,180)
								if IsControlJustPressed(0,38) and not searchProgress then
									searchProgress = true
									ClearPedTasks(ped)
									FreezeEntityPosition(ped,true)
									SetCurrentPedWeapon(ped,GetHashKey("WEAPON_UNARMED"),true)
									TriggerEvent("cancelando",true)
									vRP._playAnim(false,{{"oddjobs@shop_robbery@rob_till","loop"}},true)
									SetTimeout(2000,function()
										FreezeEntityPosition(ped,false)
										TriggerEvent("cancelando",false)
										ClearPedTasks(ped)
										vRP._stopAnim(false)
										kSERVER.searchChest(k, hasPermName)
										searchProgress = false
									end)
								end
							end
						end
					end
				end
			end
		end
		Citizen.Wait(kswait)
	end
end)

function drawTxt(text,font,x,y,scale,r,g,b,a)
	SetTextFont(font)
	SetTextScale(scale,scale)
	SetTextColour(r,g,b,a)
	SetTextOutline()
	SetTextCentre(1)
	SetTextEntry("STRING")
	AddTextComponentString(text)
	DrawText(x,y)
end

function DrawText3Ds(x,y,z,text)
	local onScreen,_x,_y = World3dToScreen2d(x,y,z)
	SetTextFont(4)
	SetTextScale(0.35,0.35)
	SetTextColour(255,255,255,150)
	SetTextEntry("STRING")
	SetTextCentre(1)
	AddTextComponentString(text)
	DrawText(_x,_y)
	local factor = (string.len(text))/370
	DrawRect(_x,_y+0.0125,0.01+factor,0.03,0,0,0,80)
end