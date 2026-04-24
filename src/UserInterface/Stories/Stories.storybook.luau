local uiRoot = script:FindFirstAncestor("UserInterface")
local pkgs = uiRoot.Parent.Parent
local ReactRoblox = require(pkgs.ReactRoblox)
local React = require(pkgs.React)

return {
	name = "Studio Properties",
	storyRoots = {
		uiRoot.Components.Properties,
		uiRoot.Components.ColorPicker,
		uiRoot.Components.VerticalScroll,
	},
	packages = {
		React = React,
		ReactRoblox = ReactRoblox,
	},
}
