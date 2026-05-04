local uiRoot = script:FindFirstAncestor("UserInterface")
local useComponents = require(uiRoot.Hooks.useComponents)

local pkgs = uiRoot.Parent.Parent
local React = require(pkgs.React)

local primitivesRoot = script.Parent.Parent.Primitives
local StringProperty = require(primitivesRoot.StringProperty)
local NumberProperty = require(primitivesRoot.NumberProperty)

export type Props = {
	AnchorPoint: Vector2?,
	Position: UDim2?,

	FieldName: string,
	ForceExpanded: boolean?,

	Value: UDim,
	OnValueSubmitted: (UDim) -> ()?,

	Indent: number?,
	LayoutOrder: number?,
	ZIndex: number?,
	Disabled: boolean?,
}

local function toArray(value: UDim)
	return { value.Scale, value.Offset }
end

local function fromArray(components: { number })
	return UDim.new(components[1], components[2])
end

local function toText(components: { number })
	return table.concat(components, ", ")
end

local function UDimProperty(props: Props)
	local indent = math.floor(math.max(1, props.Indent or 0))

	local components, updateComponents = useComponents(props.Value, toArray, fromArray)
	local text, setText = React.useState(toText(components))

	React.useEffect(function()
		setText(toText(components))
		if props.OnValueSubmitted then
			props.OnValueSubmitted(fromArray(components))
		end
	end, { components })

	return React.createElement(StringProperty, {
		FieldName = props.FieldName,
		ForceExpanded = props.ForceExpanded,

		Value = text,
		OnValueSubmitted = function(newText)
			local newComponents = {}
			local splitByComma = newText:split(",")

			newComponents[1] = tonumber(splitByComma[1]) or 0
			newComponents[2] = math.floor(tonumber(splitByComma[2]) or 0)

			updateComponents(newComponents)
			setText(toText(newComponents))
		end,

		Indent = indent,
		LayoutOrder = props.LayoutOrder,
		ZIndex = props.ZIndex,
		Disabled = props.Disabled,
	}, {
		List = React.createElement("Frame", {
			BackgroundTransparency = 1,
			Size = UDim2.fromScale(1, 1),
			AutomaticSize = Enum.AutomaticSize.Y,
		}, {
			UIListLayout = React.createElement("UIListLayout", {
				FillDirection = Enum.FillDirection.Vertical,
				SortOrder = Enum.SortOrder.LayoutOrder,
				Padding = UDim.new(0, 0),
			}),

			ScaleComponent = React.createElement(NumberProperty, {
				FieldName = "Scale",
				ForceExpanded = props.ForceExpanded,

				Value = components[1],
				OnValueSubmitted = function(n)
					local newComponents = updateComponents({ [1] = n })
					setText(toText(newComponents))
				end,

				Indent = indent + 1,
				LayoutOrder = 1,
				Disabled = props.Disabled,
			}),

			OffsetComponent = React.createElement(NumberProperty, {
				FieldName = "Offset",
				ForceExpanded = props.ForceExpanded,

				Min = 0,
				Step = 1,

				Value = components[2],
				OnValueSubmitted = function(n)
					local newComponents = updateComponents({ [2] = n })
					setText(toText(newComponents))
				end,

				Indent = indent + 1,
				LayoutOrder = 2,
				Disabled = props.Disabled,
			}),
		}),
	})
end

return UDimProperty
