return {
	-- Containers
	Group = require(script.Foundational.PropertyGroup),

	-- Primitives
	Boolean = require(script.Primitives.BooleanProperty),
	Number = require(script.Primitives.NumberProperty),
	String = require(script.Primitives.StringProperty),
	Dropdown = require(script.Primitives.DropdownProperty),
	Instance = require(script.Primitives.InstanceProperty),

	-- Roblox
	Vector2 = require(script.Roblox.Vector2Property),
	Vector3 = require(script.Roblox.Vector3Property),
	UDim = require(script.Roblox.UDimProperty),
	UDim2 = require(script.Roblox.UDim2Property),
	CFrame = require(script.Roblox.CFrameProperty),
	Color3 = require(script.Roblox.Color3Property),
}
