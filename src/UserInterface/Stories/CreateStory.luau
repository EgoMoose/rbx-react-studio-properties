--!nocheck
--!nolint UnknownGlobal

local pkgs = script:FindFirstAncestor("UserInterface").Parent.Parent
local StudioComponents = require(pkgs.StudioComponents)
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

		return React.createElement(StudioComponents.PluginProvider, {
			Plugin = plugin,
		}, {
			Component = React.createElement(component, props),
		})
	end
end

return createStory
