local uiRoot = script:FindFirstAncestor("UserInterface")
local Observables = require(uiRoot.Observables)

local pkgs = uiRoot.Parent.Parent
local StudioComponents = require(pkgs.StudioComponents)
local React = require(pkgs.React)

local foundationalRoot = script.Parent.Parent.Foundational
local PropertyLine = require(foundationalRoot.PropertyLine)

export type Props = {
	AnchorPoint: Vector2?,
	Position: UDim2?,

	FieldName: string,
	ForceExpanded: boolean?,

	Value: string,
	OnValueSubmitted: (string) -> ()?,

	List: { string },

	Indent: number?,
	LayoutOrder: number?,
	ZIndex: number?,
	Disabled: boolean?,

	children: React.ReactNode?,
}

local function DropdownProperty(props: Props)
	local isInputTracking, setIsInputTracking = React.useState(false)
	local inputObjectRef = React.useRef(nil :: InputObject?)

	React.useEffect(function()
		local connection
		if isInputTracking and inputObjectRef.current then
			connection = inputObjectRef.current:GetPropertyChangedSignal("UserInputState"):Connect(function()
				if inputObjectRef.current.UserInputState == Enum.UserInputState.Begin then
					setIsInputTracking(false)
					Observables.hoveringDisabled:set(false)
				end
			end)
		end

		return function()
			if connection then
				connection:Disconnect()
			end
		end
	end, { isInputTracking })

	return React.createElement(PropertyLine, {
		AnchorPoint = props.AnchorPoint,
		Position = props.Position,

		FieldName = props.FieldName,
		ForceExpanded = props.ForceExpanded,

		Indent = props.Indent,
		LayoutOrder = props.LayoutOrder,
		ZIndex = props.ZIndex,
		Disabled = props.Disabled,

		Interface = React.createElement(React.Fragment, nil, {
			Open = React.createElement("Frame", {
				Active = false,
				BackgroundTransparency = 1,
				Size = UDim2.fromScale(1, 1),
				ZIndex = -1,

				[React.Event.InputBegan] = function(_, input: InputObject)
					if not props.Disabled and input.UserInputType == Enum.UserInputType.MouseButton1 then
						inputObjectRef.current = input
						setIsInputTracking(true)
						Observables.hoveringDisabled:set(true)
					end
				end,
			}),

			Dropdown = React.createElement(StudioComponents.Dropdown, {
				Size = UDim2.fromScale(1, 1),
				SelectedItem = props.Value,
				Items = props.List,
				OnItemSelected = function(item)
					if props.OnValueSubmitted then
						props.OnValueSubmitted(item :: any)
					end
				end,
				Disabled = props.Disabled,
			}),
		}) :: React.ReactNode,
	}, props.children)
end

return DropdownProperty
