local uiRoot = script:FindFirstAncestor("UserInterface")
local createDockHook = require(uiRoot.Hooks.createDockHook)
local Observables = require(uiRoot.Observables)

return createDockHook({
	Id = "egomoose_react_studio_properties_color_picker",
	Title = "Select Color",
	Size = Vector2.new(520, 400),

	Open = Observables.colorPickerOpen,
	Dock = Observables.colorPickerDock,
})
