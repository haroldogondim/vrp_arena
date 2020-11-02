-----------------------------------------------------------------------------------------------------------------------------------------
-- Script desenvolvido por Kisha. Email: slentkat@gmail.com / GitHub: https://github.com/haroldogondim
-----------------------------------------------------------------------------------------------------------------------------------------
-- VRP
-----------------------------------------------------------------------------------------------------------------------------------------
local Tunnel = module("vrp","lib/Tunnel")
local Proxy = module("vrp","lib/Proxy")
vRP = Proxy.getInterface("vRP")
vRPclient = Tunnel.getInterface("vRP")
-----------------------------------------------------------------------------------------------------------------------------------------
-- HELPERS
-----------------------------------------------------------------------------------------------------------------------------------------
local function hasPerms(user_id, perms)
	local has = false
	for k,v in pairs(perms) do
		if vRP.hasPermission(user_id, v) then
			has = true
		end
	end
	return has
end

local function r_table_from_value(tabl, value)
	local tabl_rows = #tabl
	for k,v in pairs(tabl) do
		if v == value then
			tabl[k] = nil
		end
	end
end

-----------------------------------------------------------------------------------------------------------------------------------------
-- CONEXÃO
-----------------------------------------------------------------------------------------------------------------------------------------
src = {}
Tunnel.bindInterface("vrp_arena",src)
vCLIENT = Tunnel.getInterface("vrp_arena")
-----------------------------------------------------------------------------------------------------------------------------------------
-- WEBHOOK
-----------------------------------------------------------------------------------------------------------------------------------------
local webhookarena = ""

function SendWebhookMessage(webhook,message)
	if webhook ~= nil and webhook ~= "" then
		PerformHttpRequest(webhook, function(err, text, headers) end, 'POST', json.encode({content = message}), { ['Content-Type'] = 'application/json' })
	end
end

-----------------------------------------------------------------------------------------------------------------------------------------
-- VARIAVEIS
-----------------------------------------------------------------------------------------------------------------------------------------
-- Sistema de múltimas permissoes
local perms = {
	"bratva.permissao",
	"motoclub.permissao",
	"municao.permissao",
	"mcnorte.permissao"
}

-- Toggle dominação
local dominatingNow = {}

-----------------------------------------------------------------------------------------------------------------------------------------
-- COMO INICIAR?
-- EXEMPLO DE COMANDO: /dominacao start-stop bratva
-- Os blips de saque da bratva serão liberados.
-----------------------------------------------------------------------------------------------------------------------------------------

RegisterCommand('dominacao',function(source,args,rawCommand)
	if not args[1] or not args[2] then
		return
	end
	local source = source
	local user_id = vRP.getUserId(source)
	if vRP.hasPermission(user_id, "admin.permissao") then
		return
	end
	local toggle = args[1]
	local _permName = tostring(args[2])
	local permName = _permName..".permissao"
	if toggle == "start" then
		if not src.has_value(dominatingNow, permName) and src.has_value(perms, permName) then
			table.insert(dominatingNow, permName)
			TriggerClientEvent("Notify",-1,"importante","Dominação "..string.upper(_permName).." iniciada.")
		else
			print("Comando inválido")
		end
	elseif toggle == "stop" then
		r_table_from_value(dominatingNow, permName)
	end

end)

-- QUANTIDADE DE USOS POR BAÚ, DEVE TER A MESMA QUANTIDADE DE COORDENADAS DO CLIENT
local chests = {
	['bratva.permissao'] = 10,
	['motoclub.permissao'] = 10,
	['municao.permissao'] = 10,
	['mcnorte.permissao'] = 10
}

local allRewardsList = {
	['bratva.permissao'] = {
		[1] = { ['index'] = "gatilho" },
		[2] = { ['index'] = "placa-metal" }
	},

	['motoclub.permissao'] = {
		[1] = { ['index'] = "molas" }
	},

	['municao.permissao'] = {
		[1] = { ['index'] = "corpo-ak103" }
	},

	['mcnorte.permissao'] = {
		[1] = { ['index'] = "corpo-mtar" },
		[2] = { ['index'] = "corpo-pistol" }
	}
}

function src.has_value (tab, val)
    for index, value in ipairs(tab) do
        if value == val then
            return true
        end
    end

    return false
end

function src.checkPermission(perm)
	local source = source
	local user_id = vRP.getUserId(source)
	if vRP.hasPermission(user_id, perm) then
		return true
	end
	return false
end

function src.hasAnyPerm()
	local source = source
	local user_id = vRP.getUserId(source)
	if hasPerms(user_id, perms) then
		return true
	end
	return false
end

function src.isDominating()
	if #dominatingNow > 0 then
		return #dominatingNow
	end
	return false
end

function src.dominatingNow()
	return dominatingNow
end

-- Verifica a permissão dos 
function src.searchChest(ch, perm)

	local source = source
	local user_id = vRP.getUserId(source)
	
	if hasPerms(user_id, perms) then
		local selectedItem = math.random(#allRewardsList[perm])

		local rwList = {
			['bratva.permissao'] = {
				[1] = { ['index'] = "gatilho", ['qtd'] = math.random(1,5) },
				[2] = { ['index'] = "placa-metal", ['qtd'] = math.random(1,5) },
			},
		
			['motoclub.permissao'] = {
				[1] = { ['index'] = "molas", ['qtd'] = math.random(1,5) },
			},
		
			['municao.permissao'] = {
				[1] = { ['index'] = "corpo-ak103", ['qtd'] = math.random(1,5) },
			},
		
			['mcnorte.permissao'] = {
				[1] = { ['index'] = "corpo-mtar", ['qtd'] = math.random(1,5) },
				[2] = { ['index'] = "corpo-pistol", ['qtd'] = math.random(1,5) }
			}
		}
		
		if parseInt(chests[perm]) > 0 then
			local selectedName = vRP.itemNameList(rwList[perm][selectedItem].index)
			local selectedAmount = rwList[perm][selectedItem].qtd
			if vRP.getInventoryWeight(user_id)+vRP.getItemWeight(rwList[perm][selectedItem].index)*rwList[perm][selectedItem].qtd <= vRP.getInventoryMaxWeight(user_id) then
				vRP.giveInventoryItem(user_id,rwList[perm][selectedItem].index,selectedAmount)
				TriggerClientEvent("Notify",source,"sucesso","Você recebeu <b>"..selectedAmount.."x "..selectedName.."</b>.")
				chests[perm] = chests[perm] - 1
				vRPclient._stopAnim(source,false)
				return true
			else
				TriggerClientEvent("Notify",source,"aviso","Sem espaço suficiente na mochila para <b>"..selectedAmount.."x "..selectedName.."</b>.")
			end
		else
			TriggerClientEvent("Notify",source,"aviso","Este local já está vazio.")
		end
	end
end