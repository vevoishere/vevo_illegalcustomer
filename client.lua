ESX = nil
busy = false
baslat = false
sonuclanmadi = true

Citizen.CreateThread(function()

	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end
	
end)

RegisterNetEvent("vevo_illegalcustomer:start")
AddEventHandler("vevo_illegalcustomer:start", function()
	
	if GetClockHours() >= Config.MinClockHour or GetClockHours() <= Config.MaxClockHour then
		Citizen.Wait(3000)
		ExecuteCommand('phonekapat')
		vevomenuv1()
	else
		Citizen.Wait(3000)
		ExecuteCommand('phonekapat')
		TriggerEvent('mythic_notify:client:SendAlert', { type = 'error', text = 'Bu saatte buluşamayız!', length = 5000})
	end
	
end)

function vevomenuv1()
	
	maxrandom = 0
	for i = 1, #Config.MPEDS, 1 do
		maxrandom = maxrandom + 1
	end
	
	randomyavrum = math.random(1, maxrandom)
	mpedhash = Config.MPEDS[randomyavrum]
	
	
	local elements = {}
	
	for k,Vevo in pairs(Config.Product) do
		
		table.insert(elements, {
			label = (' '..Vevo.label..' - <span style="color:green;">Malın Kalitesine Göre!</span>-'),
			itemname = k,
			price = Vevo.sellprice,
			vevolabel = Vevo.label,
			-- menu properties
			type = 'slider',
			value = Vevo.minumum,
			min = Vevo.minumum,
			max = 999
		})
		
	end
	
	ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'sellerv2', {
		title    = 'Arama: 30 - Ne Satacaksın?',
		align    = 'top-left',
		elements = elements
	}, function(data, menu)
		
		if busy then
			TriggerEvent('mythic_notify:client:SendAlert', { type = 'error', text = 'Zaten çağırmışsın!', length = 5000})
		else
			TriggerEvent('mythic_notify:client:SendAlert', { type = 'success', text = 'Geliyorum, navigasyonundan konumuma bakabilirsin.', length = 5000})
			busy = true
			vevobaslayalim(data.current.value, data.current.value*data.current.price, data.current.itemname, data.current.vevolabel)
		end
		
	end, function(data, menu)
		menu.close()
	end)

end


function vevobaslayalim(miktar, totalprice, itemismi, blipname)
	
	local driverhash = GetRandom("MPED")
	local vehhash = GetRandom("VEHICLE")
	
	local player = PlayerPedId()
	local playerPos = GetEntityCoords(player)

	while not HasModelLoaded(driverhash) and RequestModel(driverhash) or not HasModelLoaded(vehhash) and RequestModel(vehhash) do
		RequestModel(driverhash)
		RequestModel(vehhash)
		Citizen.Wait(0)
	end

	SpawnVehicle(playerPos.x, playerPos.y, playerPos.z, vehhash, driverhash, miktar, totalprice, itemismi, blipname)
	
end


function SpawnVehicle(x, y, z, vehhash, driverhash, miktar, totalprice, itemismi, blipname)                                                     --Spawning Function
    local found, spawnPos, spawnHeading = GetClosestVehicleNodeWithHeading(x + math.random(-100, 100), y + math.random(-100, 100), z, 0, 3, 0)

    ESX.Game.SpawnVehicle(vehhash, spawnPos, spawnHeading, function(callback_vehicle)
        SetVehicleHasBeenOwnedByPlayer(callback_vehicle, true)
        
        SetEntityAsMissionEntity(callback_vehicle, true, true)
        ClearAreaOfVehicles(GetEntityCoords(callback_vehicle), 5000, false, false, false, false, false);  
        SetVehicleOnGroundProperly(callback_vehicle)
        --ESX.Game.SetVehicleProperties(callback_vehicle, props)
        
        mechPed = CreatePedInsideVehicle(callback_vehicle, 26, driverhash, -1, true, false)              		--Driver Spawning.
        
        mechBlip = AddBlipForEntity(callback_vehicle)                                                        	--Blip Spawning.
        SetBlipFlashes(mechBlip, true)  
        SetBlipColour(mechBlip, 1)
		
		BeginTextCommandSetBlipName('STRING')
        AddTextComponentString(blipname..' Alıcısı')
        EndTextCommandSetBlipName(mechBlip)

        GoToTarget(x, y, z, callback_vehicle, mechPed, vehhash, miktar, totalprice, itemismi)
    end)
end

function GoToTarget(x, y, z, vehicle, driver, vehhash, miktar, totalprice, itemismi)
    enroute = true
	totaltry = 0
    while enroute do
        Citizen.Wait(500)
        local player = PlayerPedId()
        local playerPos = GetEntityCoords(player)
        SetDriverAbility(driver, 1.0)        -- values between 0.0 and 1.0 are allowed.
        SetDriverAggressiveness(driver, 0.0)
        TaskVehicleDriveToCoord(driver, vehicle, playerPos.x, playerPos.y, playerPos.z, 20.0, 0, vehhash, 4457279, 1, true)
        local distanceToTarget = #(playerPos - GetEntityCoords(vehicle))
        --if distanceToTarget < 15 or distanceToTarget > 150 then
        if distanceToTarget < 15 then
            -- RemoveBlip(mechBlip)
            TaskVehicleTempAction(driver, vehicle, 27, 6000)
            --SetVehicleUndriveable(vehicle, true)
            SetEntityHealth(mechPed, 2000)
            SetPedDropsWeaponsWhenDead(mechPed, false)
            SetPedAccuracy(mechPed, 100)
            GiveWeaponToPed(mechPed, GetHashKey('WEAPON_PISTOL'), 120, 0, 1)
            SetPedCanRagdoll(mechPed, false)
            GoToTargetWalking(x, y, z, vehicle, driver, vehhash, miktar, totalprice, itemismi)
			enroute = false
		else
			totaltry = totaltry + 1
        end
		
		if totaltry == 30 then
			enroute = false
			DeletePed(mechPed)
			DeleteVehicle(vehicle)
			mechPed = nil
			TriggerEvent('mythic_notify:client:SendAlert', { type = 'error', text = 'Orospu evladı kaza yaptı! Tekrar çağır :(', length = 5000})
			busy = false
		end
		
    end
end

function GoToTargetWalking(x, y, z, vehicle, driver, vehhash, miktar, totalprice, itemismi)
	
	markeribaslat(x, y, z, driver)
	
	birseylersoyle('Araçtan malzemelerini alır.', driver, 'MEDO')
	birseylersoyle('Araçtan malzemelerini alır.', driver, 'CHAT')
	Citizen.Wait(8000)
	
	birseylersoyle('D-Dostum! Sana bir şey söyleyeyim mi? İyi malın hastasıyım.', driver, 'CHAT')
	birseylersoyle('Nerede bu lanet olası Santosun saglam malları?', driver, 'MEDO')

	
    TaskWanderStandard(driver, 10.0, 10)
    SetVehicleDoorsLocked(vehicle, 2)
    SetVehicleDoorsLockedForAllPlayers(vehicle, true)
	TaskGoToCoordAnyMeans(driver, x, y, z, 1.0, 0, 0, 786603, 1.0)
	
	Citizen.Wait(8000)
	birseylersoyle('Göster bakalım malları!', driver, 'MEDO')
	
	--print(x, y, z, vehicle, driver, vehhash, miktar, totalprice, itemismi)
	
	baslat = true
	verdi = false
	
	Citizen.CreateThread(function()
		Wait(20000)
		baslat = false
		
		if verdi == false and sonuclanmadi == true then
			TriggerEvent('mythic_notify:client:SendAlert', { type = 'error', text = 'Malları versene orospu çocuğu!', length = 5000})
			TaskCombatPed(driver, GetPlayerPed(-1), 0, 16)
			Citizen.Wait(6000)
			kacamk(x, y, z, vehicle, driver, vehhash)
		end
		
    end)
		
	Citizen.CreateThread(function()
		
		while ESX == nil do
			TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
			Citizen.Wait(0)
		end
		
		while baslat do
            Wait(0)
            local mpedcoords = GetEntityCoords(driver, false)
			local coords = GetEntityCoords(PlayerPedId(), false)
			local dist = Vdist2(coords, mpedcoords)
						
            if dist < 10 then
				Draw3DText2(mpedcoords.x, mpedcoords.y, mpedcoords.z+0.2, "~w~~g~[E]~w~ Alıcı", 0.70)
				if IsControlJustReleased(0, 38) then
					sonuclanmadi = false
					ESX.TriggerServerCallback('vevo_illegalcustomer:kontrol', function(var)
						if var then
							verdi = true
							TaskTurnPedToFaceEntity(driver, PlayerPedId(), 1.0)
							PlayAmbientSpeech1(driver, "Generic_Hi", "Speech_Params_Force")
							exports['mythic_progbar']:Progress({
								name = "talkingnpc",
								duration = 20000,
								label = 'Malları Veriyorsun..',
                                useWhileDead = false,
								canCancel = false,
								controlDisables = {
									disableMovement = true,
									disableCarMovement = true,
									disableMouse = false,
									disableCombat = true,
                                },
                                animation = {
                                    animDict = "mp_safehouselost@",
                                    anim = "package_dropoff",
                                    flags = 16,
                                },
                                prop = {
                                    model = 'hei_prop_hei_paper_bag',
                                    bone = 28422,
                                    coords = { x = 0.05, y = 0.0, z = 0.0 },
                                    rotation = { x = 135.0, y = -100.0, z = 0.0 },
                                }
                            }, function(cancelled)
                                if not cancelled then
                                    --loadAnimDict("mp_safehouselost@")
                                    --TaskPlayAnim(driver, "mp_safehouselost@", "package_dropoff", 8.0, 1.0, -1, 16, 0, 0, 0, 0)
                                    birseylersoyle('Numaranı kaydettim! Güzel işti! Daha fazla mal bekliyorum!', driver, 'CHAT')
									kacamk(x, y, z, vehicle, driver, vehhash)
									baslat = false
                                end
                            end)
						else
							
							
							exports['mythic_progbar']:Progress({
								name = "talkingnpc",
								duration = 20000,
								label = 'Malları Veriyorsun..',
                                useWhileDead = false,
								canCancel = false,
								controlDisables = {
									disableMovement = true,
									disableCarMovement = true,
									disableMouse = false,
									disableCombat = true,
                                },
                                animation = {
                                    animDict = "mp_safehouselost@",
                                    anim = "package_dropoff",
                                    flags = 16,
                                },
                            }, function(cancelled)
                                if not cancelled then
									TriggerEvent('mythic_notify:client:SendAlert', { type = 'error', text = 'Üstünde bu kadar mal yok! Taşşak mı geçiyorsun?', length = 5000})
									TaskCombatPed(driver, GetPlayerPed(-1), 0, 16)
									Citizen.Wait(6000)
									kacamk(x, y, z, vehicle, driver, vehhash)
								end
							end)
						end
					end, itemismi, miktar, totalprice)
				end
            end
        end
    end)
	
end

function birseylersoyle(text, driver, tur)
	
	if tur == "CHAT" then
		local mpedcoords = GetEntityCoords(driver, false)
		local coords = GetEntityCoords(PlayerPedId(), false)
		local dist = Vdist2(coords, mpedcoords)
			
        if dist < 250 then
			TriggerEvent('chat:addMessage', { template = '<div class="chat-message me"><b> [ALICI]: '..text..'</b> </div>'})
			return "ok"
		else
			return "sikko"
        end
	end
	
	goster = true
	
	Citizen.CreateThread(function()
		Wait(7000)
		goster = false
    end)
	
	if goster then
		
		local mpedcoords = GetEntityCoords(driver, false)
		local coords = GetEntityCoords(PlayerPedId(), false)
		local dist = Vdist2(coords, mpedcoords)
			
        if dist < 250 then
		else
			goster = false
			return "sikko"
        end
		
	end
	
	Citizen.CreateThread(function()
		
		while goster do
            Wait(0)
            local mpedcoords = GetEntityCoords(driver, false)
			local coords = GetEntityCoords(PlayerPedId(), false)
			local dist = Vdist2(coords, mpedcoords)
			
            if dist < 250 then
				DrawText3D(mpedcoords.x, mpedcoords.y, mpedcoords.z, text)
            end
        end
    end)

end

function markeribaslat(x, y, z, driver)
	
	markerigoster = true
	
	Citizen.CreateThread(function()
		Wait(30000)
		markerigoster = false
    end)

	Citizen.CreateThread(function()
		
		while markerigoster do
            Wait(0)
            local mpedcoords = GetEntityCoords(driver, false)
			local coords = GetEntityCoords(PlayerPedId(), false)
			local dist = Vdist2(coords, mpedcoords)
			
            if dist < 250 then
				DrawScriptMarker({["type"] = 6,["pos"] = vector3(x, y, z-1.0),["r"] = 255,["g"] = 0,["b"] = 0,["sizeX"] = 1.0,["sizeY"] = 1.0,["sizeZ"] = 1.0})
            end
        end
    end)
	
end

function GetRandom(tur)
	
	result = "verynill"
	
	if tur == "MPED" then
	
		mpedmaxrandom = 0
		for i = 1, #Config.MPEDS, 1 do
			mpedmaxrandom = mpedmaxrandom + 1
		end
		mpedrandomyavrum = math.random(1, mpedmaxrandom)
		driverhash = Config.MPEDS[mpedrandomyavrum]
		result = driverhash
				
	elseif tur == "VEHICLE" then
	
		vehiclesmaxrandom = 0
		for i = 1, #Config.CARS, 1 do
			vehiclesmaxrandom = vehiclesmaxrandom + 1
		end
		vehiclesrandomyavrum = math.random(1, vehiclesmaxrandom)
		vehhash = Config.CARS[vehiclesrandomyavrum]
		result = vehhash
		
	else
		result = "nil"
	end
	
	return result
	
end

function DrawText3D(x,y,z, text)

	local onScreen, _x, _y = World3dToScreen2d(x, y, z)
	local p = GetGameplayCamCoords()
	local distance = GetDistanceBetweenCoords(p.x, p.y, p.z, x, y, z, 1)
	local scale = (1 / distance) * 2
	local fov = (1 / GetGameplayCamFov()) * 100
	local scale = scale * fov

	if onScreen then

		SetTextScale(0.7, 0.7)
		SetTextFont(4)
		SetTextProportional(1)
		-- SetTextColour(255, 255, 255, 215)
		SetTextColour(204, 0, 204, 225)
		SetTextEntry("STRING")
		SetTextCentre(1)
		AddTextComponentString(text)
		DrawText(_x,_y)
		--local factor = (string.len(text)) / 370
		--DrawRect(_x,_y+0.0125, 0.030+ factor, 0.03, 0, 0, 0, 125)
		
		--local factor = (string.len(text)) / 100
		--DrawRect(_x, _y + 0.015, factor, 0.04, 0, 0, 0, 150)

    end
end

function Draw3DText2(x,y,z,text,size)
    local onScreen,_x,_y=World3dToScreen2d(x,y,z)
    local px,py,pz=table.unpack(GetGameplayCamCoords())
    SetTextScale(0.35,0.35)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    SetTextEntry("STRING")
    SetTextCentre(1)
    AddTextComponentString(text)
    DrawText(_x,_y)
    local factor = (string.len(text)) / 370
    --DrawRect(_x,_y+0.0125, 0.015+ factor, 0.03, 41, 11, 41, 68)
    DrawRect(_x,_y+0.0125, 0.015+ factor, 0.03, 41, 11, 41, 100)
end

function kacamk(x, y, z, vehicle, driver, vehhash)
	
	SetVehicleDoorsLocked(vehicle, 0)
	local found, spawnPos, spawnHeading = GetClosestVehicleNodeWithHeading(x + math.random(-100, 100), y + math.random(-100, 100), z, 0, 3, 0)
	TaskVehicleDriveToCoord(driver, vehicle, spawnPos.x, spawnPos.y, spawnPos.z, 20.0, 0, vehhash, 4457279, 1, true)
	Citizen.Wait(8000)
	DeletePed(mechPed)
	DeleteVehicle(vehicle)
    mechPed = nil
	busy = false
	
end

loadAnimDict = function(dick)
    while not HasAnimDictLoaded(dick) do
        RequestAnimDict(dick)
        Citizen.Wait(5)
    end
end

DrawScriptMarker = function(markerData)
	DrawMarker(markerData["type"] or 1, markerData["pos"] or vector3(0.0, 0.0, 0.0), 0.0, 0.0, 0.0, (markerData["type"] == 6 and -90.0 or markerData["rotate"] and -180.0) or 0.0, 0.0, 0.0, markerData["sizeX"] or 1.0, markerData["sizeY"] or 1.0, markerData["sizeZ"] or 1.0, markerData["r"] or 1.0, markerData["g"] or 1.0, markerData["b"] or 1.0, 100, markerData["bob"] and true or false, true, 2, false, false, false, false)
end
