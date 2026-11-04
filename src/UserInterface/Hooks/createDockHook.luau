local uiRoot = script:FindFirstAncestor("UserInterface")
local ObservableValue = require(uiRoot.Observables.ObservableValue)
local usePlugin = require(uiRoot.Hooks.usePlugin)

local pkgs = uiRoot.Parent.Parent
local React = require(pkgs.React)
local Trove = require(pkgs.Trove)

local DOCK_HEADER_HEIGHT = 24

export type Config = {
	Id: string,
	Title: string,
	Size: Vector2,

	Open: ObservableValue.ObservableValue<boolean>,
	Dock: ObservableValue.ObservableValue<DockWidgetPluginGui?>,
}

local function createDockHook(config: Config)
	local dockSize = config.Size + Vector2.new(0, DOCK_HEADER_HEIGHT)
	local dockInfo = DockWidgetPluginGuiInfo.new(
		Enum.InitialDockState.Float, -- Widget will be initialized in floating panel
		false, -- Widget will be initially enabled
		false, -- Don't override the previous enabled state
		dockSize.X, -- Default width of the floating window
		dockSize.Y, -- Default height of the floating window
		dockSize.X, -- Minimum width of the floating window
		dockSize.Y -- Minimum height of the floating window
	)

	return function(): (boolean, DockWidgetPluginGui?, (boolean) -> ())
		local plugin = usePlugin()

		local isOpen, setIsOpen = React.useState(false)
		local globalOpen = config.Open:use()
		local dock = config.Dock:use()

		local setDockOpen = React.useCallback(function(value: boolean)
			setIsOpen(value)
			config.Open:set(value)
		end, {})

		React.useEffect(function()
			if not globalOpen then
				setIsOpen(false)
			end
		end, { globalOpen })

		React.useEffect(function()
			if plugin and not config.Dock:get() then
				local trove = Trove.new()

				local newDock = plugin:CreateDockWidgetPluginGuiAsync(config.Id, dockInfo)
				newDock.Title = config.Title
				newDock.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
				config.Dock:set(newDock)

				trove:Add(function()
					config.Dock:set(nil)
					newDock:Destroy() -- idk why but this causes a switch to the viewport
				end)

				newDock:BindToClose(function()
					config.Open:set(false)
				end)

				trove:Add(plugin.Destroying:Once(function()
					trove:Destroy()
				end))

				trove:Add(plugin.Unloading:Once(function()
					trove:Destroy()
				end))
			end
		end, { plugin })

		if dock then
			dock.Enabled = globalOpen
		end

		return isOpen and globalOpen, dock, setDockOpen
	end
end

return createDockHook
