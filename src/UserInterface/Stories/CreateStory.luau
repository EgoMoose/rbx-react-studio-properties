--!nocheck
--!nolint

local uiRoot = script:FindFirstAncestor("UserInterface")
local PluginContext = require(uiRoot.Contexts.PluginContext)

local pkgs = uiRoot.Parent.Parent
local React = require(pkgs.React)

-- selene: allow(undefined_variable)
local plugin: Plugin = PluginManager():CreatePlugin()

local function createStory(component: React.FC<any>)
	return function(props: any)
		React.useEffect(function()
			return function()
				plugin:Destroy()
			end
		end, {})

		return React.createElement(PluginContext.Provider, {
			value = plugin,
		}, {
			Component = React.createElement(component, props),
		})
	end
end

return createStory
