local uiRoot = script:FindFirstAncestor("UserInterface")
local PluginContext = require(uiRoot.Contexts.PluginContext)

local pkgs = uiRoot.Parent.Parent
local React = require(pkgs.React)

local function usePlugin()
	local contextPlugin = React.useContext(PluginContext)
	return contextPlugin
end

return usePlugin
