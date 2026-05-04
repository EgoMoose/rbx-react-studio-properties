local uiRoot = script:FindFirstAncestor("UserInterface")
local useComponents = require(uiRoot.Hooks.useComponents)

local pkgs = uiRoot.Parent.Parent
local React = require(pkgs.React)

local primitivesRoot = script.Parent.Parent.Primitives
local StringProperty = require(primitivesRoot.StringProperty)
local UDimProperty = require(script.Parent.UDimProperty)

export type Props = {
	AnchorPoint: Vector2?,
	Position: UDim2?,

	FieldName: string,
	ForceExpanded: boolean?,

	Value: UDim2,
	OnValueSubmitted: (UDim2) -> ()?,

	Indent: number?,
	LayoutOrder: number?,
	ZIndex: number?,
	Disabled: boolean?,
}

local function toArray(value: UDim2)
	return { value.X.Scale, value.X.Offset, value.Y.Scale, value.Y.Offset }
end

local function fromArray(components: { number })
	return UDim2.new(components[1], components[2], components[3], components[4])
end

local function toText(components: { number })
	return `\{{table.concat(components, ", ", 1, 2)}\}, \{{table.concat(components, ", ", 3, 4)}\}`
end

local function UDim2Property(props: Props)
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
			local splitByComma = newText:gsub("[{}]", ""):split(",")

			newComponents[1] = tonumber(splitByComma[1]) or 0
			newComponents[2] = math.floor(tonumber(splitByComma[2]) or 0)
			newComponents[3] = tonumber(splitByComma[3]) or 0
			newComponents[4] = math.floor(tonumber(splitByComma[4]) or 0)

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

			XComponent = React.createElement(UDimProperty, {
				FieldName = "X",
				ForceExpanded = props.ForceExpanded,

				Value = UDim.new(components[1], components[2]),
				OnValueSubmitted = function(ud)
					local newComponents = updateComponents({ [1] = ud.Scale, [2] = ud.Offset })
					setText(toText(newComponents))
				end,

				Indent = indent + 1,
				LayoutOrder = 1,
				Disabled = props.Disabled,
			}),

			YComponent = React.createElement(UDimProperty, {
				FieldName = "Y",
				ForceExpanded = props.ForceExpanded,

				Value = UDim.new(components[3], components[4]),
				OnValueSubmitted = function(ud)
					local newComponents = updateComponents({ [3] = ud.Scale, [4] = ud.Offset })
					setText(toText(newComponents))
				end,

				Indent = indent + 1,
				LayoutOrder = 2,
				Disabled = props.Disabled,
			}),
		}),
	})
end

return UDim2Property
