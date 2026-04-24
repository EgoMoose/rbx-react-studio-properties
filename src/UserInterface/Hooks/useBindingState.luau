--[[
The MIT License (MIT)

Copyright (c) 2024 Littensy

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.

Based off of this hook:
https://github.com/littensy/pretty-react-hooks/tree/master/src/use-binding-state
--]]

local pkgs = script:FindFirstAncestor("UserInterface").Parent.Parent
local React = require(pkgs.React)

type BindingAPI<T> = {
	subscribe: (callback: (T) -> ()) -> () -> (),
	update: (T) -> (),
	getValue: () -> T,
}

local function getBindingAPI<T>(binding: React.Binding<T>): BindingAPI<T>?
	for key, value in binding :: any do
		local name = tostring(key)
		if name == "Symbol(BindingImpl)" then
			return value :: BindingAPI<T>
		end
	end
	return nil
end

local function useBindingState<T>(binding: React.Binding<T>): T
	local value, setValue = React.useState(binding:getValue())

	React.useEffect(function()
		setValue(binding:getValue())
		local api = getBindingAPI(binding)
		return if api then api.subscribe(setValue) else nil
	end, { binding })

	return value
end

return useBindingState
