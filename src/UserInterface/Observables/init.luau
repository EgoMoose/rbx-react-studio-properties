local ObservableValue = require(script.ObservableValue)

return {
	hoveringDisabled = ObservableValue.new(false),
	colorPickerOpen = ObservableValue.new(false),
	colorPickerDock = ObservableValue.new(nil :: DockWidgetPluginGui?),
	customColors = ObservableValue.new(table.create(16, Color3.new(1, 1, 1))),
}
