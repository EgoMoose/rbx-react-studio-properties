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

	Value: Vector3,
	OnValueSubmitted: (Vector3) -> ()?,

	Indent: number?,
	LayoutOrder: number?,
	ZIndex: number?,
	Disabled: boolean?,
}

local function toArray(value: Vector3)
	return { value.X, value.Y, value.Z }
end

local function fromArray(components: { number })
	return Vector3.new(components[1], components[2], components[3])
end

local function toText(components: { number })
	return table.concat(components, ", ")
end

local function Vector3Property(props: Props)
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

		Value = text,
		OnValueSubmitted = function(newText)
			local newComponents = {}
			local splitByComma = newText:split(",")
			for i = 1, 3 do
				newComponents[i] = tonumber(splitByComma[i]) or 0
			end
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

			XComponent = React.createElement(NumberProperty, {
				FieldName = "X",

				Value = components[1],
				OnValueSubmitted = function(n)
					local newComponents = updateComponents({ [1] = n })
					setText(toText(newComponents))
				end,

				Indent = indent + 1,
				LayoutOrder = 1,
				Disabled = props.Disabled,
			}),

			YComponent = React.createElement(NumberProperty, {
				FieldName = "Y",

				Value = components[2],
				OnValueSubmitted = function(n)
					local newComponents = updateComponents({ [2] = n })
					setText(toText(newComponents))
				end,

				Indent = indent + 1,
				LayoutOrder = 2,
				Disabled = props.Disabled,
			}),

			ZComponent = React.createElement(NumberProperty, {
				FieldName = "Z",

				Value = components[3],
				OnValueSubmitted = function(n)
					local newComponents = updateComponents({ [3] = n })
					setText(toText(newComponents))
				end,

				Indent = indent + 1,
				LayoutOrder = 3,
				Disabled = props.Disabled,
			}),
		}),
	})
end

return Vector3Property
