local uiRoot = script:FindFirstAncestor("UserInterface")
local Observables = require(uiRoot.Observables)

local pkgs = uiRoot.Parent.Parent
local StudioComponents = require(pkgs.StudioComponents)
local React = require(pkgs.React)
local Trove = require(pkgs.Trove)

local DOCK_ID = "egomoose_react_studio_properties_color_picker"
local DOCK_HEADER_HEIGHT = 24

local DOCK_SIZE = Vector2.new(520, 400 + DOCK_HEADER_HEIGHT)
local DOCK_INFO = DockWidgetPluginGuiInfo.new(
	Enum.InitialDockState.Float, -- Widget will be initialized in floating panel
	false, -- Widget will be initially enabled
	false, -- Don't override the previous enabled state
	DOCK_SIZE.X, -- Default width of the floating window
	DOCK_SIZE.Y, -- Default height of the floating window
	DOCK_SIZE.X, -- Minimum width of the floating window
	DOCK_SIZE.Y -- Minimum height of the floating window
)

local function useColorPickerDock()
	local plugin = StudioComponents.usePlugin()

	local isOpen, setIsOpen = React.useState(false)
	local colorPickerOpen = Observables.colorPickerOpen:use()
	local colorPickerDock = Observables.colorPickerDock:use()

	local setColorPickerOpen = React.useCallback(function(value: boolean)
		setIsOpen(value)
		Observables.colorPickerOpen:set(value)
	end, {})

	React.useEffect(function()
		if plugin and not Observables.colorPickerDock:get() then
			local trove = Trove.new()

			local dock = plugin:CreateDockWidgetPluginGuiAsync(DOCK_ID, DOCK_INFO)
			dock.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
			Observables.colorPickerDock:set(dock)

			trove:Add(function()
				Observables.colorPickerDock:set(nil)
				dock:Destroy() -- idk why but this causes a switch to the viewport
			end)

			dock:BindToClose(function()
				setColorPickerOpen(false)
			end)

			trove:Add(plugin.Destroying:Once(function()
				trove:Destroy()
			end))

			trove:Add(plugin.Unloading:Once(function()
				trove:Destroy()
			end))
		end
	end, { plugin })

	if colorPickerDock then
		colorPickerDock.Enabled = colorPickerOpen
	end

	return isOpen, colorPickerDock, setColorPickerOpen
end

return useColorPickerDock
