local uiRoot = script:FindFirstAncestor("UserInterface")
local createDockHook = require(uiRoot.Hooks.createDockHook)
local Observables = require(uiRoot.Observables)

return createDockHook({
	Id = "egomoose_react_studio_properties_color_sequence_picker",
	Title = "ColorSequence Editor",
	Size = Vector2.new(600, 130),

	Open = Observables.colorSequencePickerOpen,
	Dock = Observables.colorSequencePickerDock,
})
