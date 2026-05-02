local uiRoot = script.UserInterface
local Properties = uiRoot.Components.Properties

return {
	PluginContext = require(uiRoot.Contexts.PluginContext),

	VerticalScroll = require(uiRoot.Components.VerticalScroll),
	ColorPicker = require(uiRoot.Components.ColorPicker),

	PropertyGroup = require(Properties.Foundational.PropertyGroup),

	-- Primitives
	Boolean = require(Properties.Primitives.BooleanProperty),
	Number = require(Properties.Primitives.NumberProperty),
	String = require(Properties.Primitives.StringProperty),
	Dropdown = require(Properties.Primitives.DropdownProperty),
	Instance = require(Properties.Primitives.InstanceProperty),

	-- Roblox
	Vector2 = require(Properties.Roblox.Vector2Property),
	Vector3 = require(Properties.Roblox.Vector3Property),
	UDim = require(Properties.Roblox.UDimProperty),
	UDim2 = require(Properties.Roblox.UDim2Property),
	CFrame = require(Properties.Roblox.CFrameProperty),
	Color3 = require(Properties.Roblox.Color3Property),
}
