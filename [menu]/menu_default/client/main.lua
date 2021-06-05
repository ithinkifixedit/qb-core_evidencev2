QBCore = nil

Citizen.CreateThread(function()
	while QBCore == nil do
		TriggerEvent("QBCore:GetObject", function(obj) QBCore = obj end)    
		Citizen.Wait(200)
	end

	local GUI      = {}
	GUI.Time       = 0
	local MenuType = 'default'

	local openMenu = function(namespace, name, data)
		SendNUIMessage({
			action    = 'openMenu',
			namespace = namespace,
			name      = name,
			data      = data,
		})
	end

	local closeMenu = function(namespace, name)
		SendNUIMessage({
			action    = 'closeMenu',
			namespace = namespace,
			name      = name,
			data      = data,
		})
	end

	QBCore.UI.Menu.RegisterType(MenuType, openMenu, closeMenu)

	RegisterNUICallback('menu_submit', function(data, cb)
		local menu = QBCore.UI.Menu.GetOpened(MenuType, data._namespace, data._name)
		
		if menu.submit ~= nil then
			menu.submit(data, menu)
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

		for i=1, #data.elements, 1 do
			menu.setElement(i, 'value', data.elements[i].value)

			if data.elements[i].selected then
				menu.setElement(i, 'selected', true)
			else
				menu.setElement(i, 'selected', false)
			end

		end

		if menu.change ~= nil then
			menu.change(data, menu)
		end

		cb('OK')
	end)

	Citizen.CreateThread(function()
		while true do
			if IsControlPressed(0, 18) and GetLastInputMethod(2) and (GetGameTimer() - GUI.Time) > 150 then
				SendNUIMessage({
					action  = 'controlPressed',
					control = 'ENTER'
				})

				GUI.Time = GetGameTimer()
			end

			if IsControlPressed(0, 177) and GetLastInputMethod(2) and (GetGameTimer() - GUI.Time) > 150 then
				SendNUIMessage({
					action  = 'controlPressed',
					control = 'BACKSPACE'
				})

				GUI.Time = GetGameTimer()
			end

			if IsControlPressed(0, 27) and GetLastInputMethod(2) and (GetGameTimer() - GUI.Time) > 250 then
				SendNUIMessage({
					action  = 'controlPressed',
					control = 'TOP'
				})

				GUI.Time = GetGameTimer()
			end

			if IsControlPressed(0, 173) and GetLastInputMethod(2) and (GetGameTimer() - GUI.Time) > 250 then
				SendNUIMessage({
					action  = 'controlPressed',
					control = 'DOWN'
				})

				GUI.Time = GetGameTimer()
			end

			if IsControlPressed(0, 174) and GetLastInputMethod(2) and (GetGameTimer() - GUI.Time) > 500 then
				SendNUIMessage({
					action  = 'controlPressed',
					control = 'LEFT'
				})

				GUI.Time = GetGameTimer()
			end

			if IsControlPressed(0, 175) and GetLastInputMethod(2) and (GetGameTimer() - GUI.Time) > 500 then
				SendNUIMessage({
					action  = 'controlPressed',
					control = 'RIGHT'
				})

				GUI.Time = GetGameTimer()
			end
			Citizen.Wait(1)
		end
	end)
end)
