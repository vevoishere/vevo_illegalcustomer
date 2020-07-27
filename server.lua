ESX = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

--[[
local DISCORDS_WEBHOOK = "https://discordapp.com/api/webhooks/711254425963987107/D0Wqu4DrqmakvSvXeQsGJ1vS7hMOYmAMsx7t4H4YZABxpHPApUqbfyFvD5hD0blN81il"
local DISCORDS_NAME = "Vevo'nun Kölesi"
local DISCORDS_IMAGE = "https://cdn.discordapp.com/attachments/677985295928655885/708860434022924338/73ec697e-f857-443f-b895-0b8f8aee499b.jpg" -- default is FiveM logo

function sendToDiscord(name, message, color)
  local connect = {
        {
            ["color"] = color,
            ["title"] = "**".. name .."**",
            ["description"] = message,
            ["footer"] = {
            ["text"] = os.date('!%Y-%m-%d - %H:%M:%S') .. " & Made by Vevo",
            },
        }
    }
  PerformHttpRequest(DISCORDS_WEBHOOK, function(err, text, headers) end, 'POST', json.encode({username = DISCORDS_NAME, embeds = connect, avatar_url = DISCORDS_IMAGE}), { ['Content-Type'] = 'application/json' })
end
--]]

RegisterServerEvent('gcPhone:startCall')
AddEventHandler('gcPhone:startCall', function(phone_number)
	if phone_number == '30' then
		TriggerClientEvent('vevo_illegalcustomer:start', source)
	end
end)


ESX.RegisterServerCallback('vevo_illegalcustomer:kontrol', function(source, cb, itemname, adet, totalprice)

	local xPlayer = ESX.GetPlayerFromId(source)
	local count = xPlayer.getInventoryItem(itemname).count
	
	if count >= adet then
		cb(true)
		xPlayer.removeInventoryItem(itemname, adet)
		if Config.Black then
			xPlayer.addInventoryItem("black", totalprice)
		else
			xPlayer.addMoney(totalprice)
		end
	else
		cb(false)
	end
	
end)
