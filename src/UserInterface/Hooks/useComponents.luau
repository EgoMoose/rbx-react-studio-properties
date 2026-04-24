local pkgs = script:FindFirstAncestor("UserInterface").Parent.Parent
local React = require(pkgs.React)

local function useComponents<T>(value: T, toArray: (T) -> { number }, fromArray: ({ number }) -> T)
	local valueRef = React.useRef(value)
	local components, setComponents = React.useState(toArray(value))

	local function updateComponents(newComponents: { number? })
		local mutated = false
		local copy = table.clone(components)

		for i, component in newComponents do
			if component and components[i] ~= component then
				mutated = true
				copy[i] = component
			end
		end

		if mutated then
			valueRef.current = fromArray(copy)
			setComponents(copy)
		end

		return copy
	end

	React.useEffect(function()
		if value ~= valueRef.current then
			valueRef.current = value
			setComponents(toArray(value))
		end
	end, { value })

	return components, updateComponents
end

return useComponents
