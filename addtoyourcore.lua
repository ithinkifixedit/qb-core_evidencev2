-- Add these to your qb-core > client > functions.lua
QBCore.UI                        = {}
QBCore.UI.HUD                    = {}
QBCore.UI.HUD.RegisteredElements = {}
QBCore.UI.Menu                   = {}
QBCore.UI.Menu.RegisteredTypes   = {}
QBCore.UI.Menu.Opened            = {}

QBCore.UI.HUD.SetDisplay = function(opacity)
	SendNUIMessage({
		action  = 'setHUDDisplay',
		opacity = opacity
	})
end

QBCore.UI.HUD.RegisterElement = function(name, index, priority, html, data)
	local found = false

	for i=1, #QBCore.UI.HUD.RegisteredElements, 1 do
		if QBCore.UI.HUD.RegisteredElements[i] == name then
			found = true
			break
		end
	end

	if found then
		return
	end

	table.insert(QBCore.UI.HUD.RegisteredElements, name)
	SendNUIMessage({
		action    = 'insertHUDElement',
		name      = name,
		index     = index,
		priority  = priority,
		html      = html,
		data      = data
	})

	QBCore.UI.HUD.UpdateElement(name, data)
end

QBCore.UI.HUD.RemoveElement = function(name)
	for i=1, #QBCore.UI.HUD.RegisteredElements, 1 do
		if QBCore.UI.HUD.RegisteredElements[i] == name then
			table.remove(QBCore.UI.HUD.RegisteredElements, i)
			break
		end
	end

	SendNUIMessage({
		action    = 'deleteHUDElement',
		name      = name
	})
end

QBCore.UI.HUD.UpdateElement = function(name, data)
	SendNUIMessage({
		action = 'updateHUDElement',
		name   = name,
		data   = data
	})
end

QBCore.UI.Menu.RegisterType = function(type, open, close)
	QBCore.UI.Menu.RegisteredTypes[type] = {
		open   = open,
		close  = close
	}
end

QBCore.UI.Menu.Open = function(type, namespace, name, data, submit, cancel, change, close)
	local menu = {}

	menu.type      = type
	menu.namespace = namespace
	menu.name      = name
	menu.data      = data
	menu.submit    = submit
	menu.cancel    = cancel
	menu.change    = change

	menu.close = function()

		QBCore.UI.Menu.RegisteredTypes[type].close(namespace, name)

		for i=1, #QBCore.UI.Menu.Opened, 1 do
			if QBCore.UI.Menu.Opened[i] then
				if QBCore.UI.Menu.Opened[i].type == type and QBCore.UI.Menu.Opened[i].namespace == namespace and QBCore.UI.Menu.Opened[i].name == name then
					QBCore.UI.Menu.Opened[i] = nil
				end
			end
		end

		if close then
			close()
		end

	end

	menu.update = function(query, newData)

		for i=1, #menu.data.elements, 1 do
			local match = true

			for k,v in pairs(query) do
				if menu.data.elements[i][k] ~= v then
					match = false
				end
			end

			if match then
				for k,v in pairs(newData) do
					menu.data.elements[i][k] = v
				end
			end
		end

	end

	menu.refresh = function()
		QBCore.UI.Menu.RegisteredTypes[type].open(namespace, name, menu.data)
	end

	menu.setElement = function(i, key, val)
		menu.data.elements[i][key] = val
	end
	
	menu.setElements = function(newElements)
		menu.data.elements = newElements
	end

	menu.setTitle = function(val)
		menu.data.title = val
	end

	menu.removeElement = function(query)
		for i=1, #menu.data.elements, 1 do
			for k,v in pairs(query) do
				if menu.data.elements[i] then
					if menu.data.elements[i][k] == v then
						table.remove(menu.data.elements, i)
						break
					end
				end

			end
		end
	end

	table.insert(QBCore.UI.Menu.Opened, menu)
	QBCore.UI.Menu.RegisteredTypes[type].open(namespace, name, data)

	return menu
end

QBCore.UI.Menu.Close = function(type, namespace, name)
	for i=1, #QBCore.UI.Menu.Opened, 1 do
		if QBCore.UI.Menu.Opened[i] then
			if QBCore.UI.Menu.Opened[i].type == type and QBCore.UI.Menu.Opened[i].namespace == namespace and QBCore.UI.Menu.Opened[i].name == name then
				QBCore.UI.Menu.Opened[i].close()
				QBCore.UI.Menu.Opened[i] = nil
			end
		end
	end
end

QBCore.UI.Menu.CloseAll = function()
	for i=1, #QBCore.UI.Menu.Opened, 1 do
		if QBCore.UI.Menu.Opened[i] then
			QBCore.UI.Menu.Opened[i].close()
			QBCore.UI.Menu.Opened[i] = nil
		end
	end
end

QBCore.UI.Menu.GetOpened = function(type, namespace, name)
	for i=1, #QBCore.UI.Menu.Opened, 1 do
		if QBCore.UI.Menu.Opened[i] then
			if QBCore.UI.Menu.Opened[i].type == type and QBCore.UI.Menu.Opened[i].namespace == namespace and QBCore.UI.Menu.Opened[i].name == name then
				return QBCore.UI.Menu.Opened[i]
			end
		end
	end
end

QBCore.UI.Menu.GetOpenedMenus = function()
	return QBCore.UI.Menu.Opened
end

QBCore.UI.Menu.IsOpen = function(type, namespace, name)
	return QBCore.UI.Menu.GetOpened(type, namespace, name) ~= nil
end

QBCore.UI.HUD.SetDisplay = function(opacity)
	SendNUIMessage({
		action  = 'setHUDDisplay',
		opacity = opacity
	})
end