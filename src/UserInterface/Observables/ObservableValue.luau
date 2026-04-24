local pkgs = script:FindFirstAncestor("UserInterface").Parent.Parent
local Signal = require(pkgs.Signal)
local React = require(pkgs.React)

local ObservableValueStatic = {}

local ObservableValueClass = {}
ObservableValueClass.__index = ObservableValueClass
ObservableValueClass.ClassName = "ObservableValue"

export type Observable<T> = typeof(setmetatable(
	{} :: {
		value: T,
		setSignal: Signal.Signal<()>,
	},
	ObservableValueClass
))

function ObservableValueStatic.new<T>(value: T)
	local self = setmetatable({}, ObservableValueClass) :: Observable<T>

	self.value = value
	self.setSignal = Signal.new()

	return self
end

function ObservableValueClass.get<T>(self: Observable<T>)
	return self.value
end

function ObservableValueClass.set<T>(self: Observable<T>, value: T)
	self.value = value
	self.setSignal:Fire()
end

function ObservableValueClass.use<T>(self: Observable<T>)
	local value, setValue = React.useState(self.value)

	React.useEffect(function()
		setValue(self.value)
		local connection = self.setSignal:Connect(function()
			setValue(self.value)
		end)

		return function()
			connection:Disconnect()
		end
	end, {})

	return value
end

function ObservableValueClass.Destroy<T>(self: Observable<T>)
	self.setSignal:Destroy()
end

return ObservableValueStatic
