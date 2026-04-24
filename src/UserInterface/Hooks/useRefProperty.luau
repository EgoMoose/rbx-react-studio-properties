local pkgs = script:FindFirstAncestor("UserInterface").Parent.Parent
local React = require(pkgs.React)

local function useRefProperty<T>(ref: { current: Instance? }, property: string, default: T)
	local value, setValue = React.useState(default)

	React.useEffect(function()
		if not ref.current then
			setValue(default)
			return
		end

		setValue((ref.current :: any)[property])
		local connection = ref.current:GetPropertyChangedSignal(property):Connect(function()
			setValue((ref.current :: any)[property])
		end)

		return function()
			connection:Disconnect()
		end
	end, { ref.current, property } :: { any })

	return value
end

return useRefProperty
