local uiRoot = script:FindFirstAncestor("UserInterface")
local Observables = require(uiRoot.Observables)

local function useColorSequencePickerOpen()
	local colorSequencePickerOpen = Observables.colorSequencePickerOpen:use()
	return colorSequencePickerOpen
end

return useColorSequencePickerOpen
