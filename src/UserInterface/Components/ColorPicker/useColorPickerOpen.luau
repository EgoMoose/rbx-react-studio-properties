local uiRoot = script:FindFirstAncestor("UserInterface")
local Observables = require(uiRoot.Observables)

local function useColorPickerOpen()
	local colorPickerOpen = Observables.colorPickerOpen:use()
	return colorPickerOpen
end

return useColorPickerOpen
