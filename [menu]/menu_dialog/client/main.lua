Citizen.CreateThread(function()
	-- internal variables
	QBCore               = nil
	local Timeouts    = {}
	local GUI         = {}
	GUI.Time          = 0
	local MenuType    = 'dialog'
	local OpenedMenus = {}

	while QBCore == nil do
		TriggerEvent("QBCore:GetObject", function(obj) QBCore = obj end)    
		Citizen.Wait(200)
	end

	local openMenu = function(namespace, name, data)
		for i=1, #Timeouts, 1 do
			QBCore.ClearTimeout(Timeouts[i])
		end

		OpenedMenus[namespace .. '_' .. name] = true

		SendNUIMessage({
			action    = 'openMenu',
			namespace = namespace,
			name      = name,
			data      = data
		})

		local timeoutId = QBCore.SetTimeout(200, function()
			SetNuiFocus(true, true)
		end)

		table.insert(Timeouts, timeoutId)
	end

	local closeMenu = function(namespace, name)
		OpenedMenus[namespace .. '_' .. name] = nil
		local OpenedMenuCount                 = 0

		SendNUIMessage({
			action    = 'closeMenu',
			namespace = namespace,
			name      = name,
			data      = data
		})

		for k,v in pairs(OpenedMenus) do
			if v == true then
				OpenedMenuCount = OpenedMenuCount + 1
			end
		end

		if OpenedMenuCount == 0 then
			SetNuiFocus(false)
		end

	end

	QBCore.UI.Menu.RegisterType(MenuType, openMenu, closeMenu)

	RegisterNUICallback('menu_submit', function(data, cb)
		local menu = QBCore.UI.Menu.GetOpened(MenuType, data._namespace, data._name)
		local post = true

		if menu.submit ~= nil then

			-- Is the submitted data a number?
			if tonumber(data.value) ~= nil then

				-- Round float values
				data.value = QBCore.Shared.Round(tonumber(data.value))

				-- Check for negative value
				if tonumber(data.value) <= 0 then
					post = false
				end
			end

			data.value = QBCore.Shared.Trim(data.value)

			-- Don't post if the value is negative or if it's 0
			if post then
				menu.submit(data, menu)
			else
				TriggerEvent("QBCore:Notify", "Hatalı Değer", "error")
			end
		end

		cb('OK')
	end)

	RegisterNUICallback('menu_cancel', function(data, cb)
		local menu = QBCore.UI.Menu.GetOpened(MenuType, data._namespace, data._name)

		if menu.cancel ~= nil then
			menu.cancel(data, menu)
		end

		cb('OK')
	end)

	RegisterNUICallback('menu_change', function(data, cb)
		local menu = QBCore.UI.Menu.GetOpened(MenuType, data._namespace, data._name)

		if menu.change ~= nil then
			menu.change(data, menu)
		end

		cb('OK')
	end)

	Citizen.CreateThread(function()
		while true do
			Citizen.Wait(1)
			local OpenedMenuCount = 0

			for k,v in pairs(OpenedMenus) do
				if v == true then
					OpenedMenuCount = OpenedMenuCount + 1
				end
			end

			if OpenedMenuCount > 0 then
				DisableControlAction(0, 1,   true) -- LookLeftRight
				DisableControlAction(0, 2,   true) -- LookUpDown
				DisableControlAction(0, 142, true) -- MeleeAttackAlternate
				DisableControlAction(0, 106, true) -- VehicleMouseControlOverride
				DisableControlAction(0, 12, true) -- WeaponWheelUpDown
				DisableControlAction(0, 14, true) -- WeaponWheelNext
				DisableControlAction(0, 15, true) -- WeaponWheelPrev
				DisableControlAction(0, 16, true) -- SelectNextWeapon
				DisableControlAction(0, 17, true) -- SelectPrevWeapon
			else
				Citizen.Wait(500)
			end
		end
	end)
end)