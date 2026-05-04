local uiRoot = script:FindFirstAncestor("UserInterface")
local useComponents = require(uiRoot.Hooks.useComponents)

local pkgs = uiRoot.Parent.Parent
local React = require(pkgs.React)

local primitivesRoot = script.Parent.Parent.Primitives
local StringProperty = require(primitivesRoot.StringProperty)
local Vector3Property = require(script.Parent.Vector3Property)

export type Props = {
	AnchorPoint: Vector2?,
	Position: UDim2?,

	FieldName: string,
	ForceExpanded: boolean?,

	Value: CFrame,
	OnValueSubmitted: (CFrame) -> ()?,

	Indent: number?,
	LayoutOrder: number?,
	ZIndex: number?,
	Disabled: boolean?,
}

local function deg(x: number)
	local d = math.deg(x)
	return if d == 0 then 0 else d
end

local function toArray(value: CFrame)
	local rx, ry, rz = value:ToEulerAngles(Enum.RotationOrder.YXZ)
	return { value.X, value.Y, value.Z, deg(rx), deg(ry), deg(rz) }
end

local function fromArray(components: { number })
	return CFrame.new(components[1], components[2], components[3])
		* CFrame.fromEulerAngles(
			math.rad(components[4]),
			math.rad(components[5]),
			math.rad(components[6]),
			Enum.RotationOrder.YXZ
		)
end

local function toText(components: { number })
	return `\{{table.concat(components, ",", 1, 3)}\}, \{{table.concat(components, ",", 4, 6)}\}`
end

local function CFrameProperty(props: Props)
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

			for i = 1, 6 do
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

			PositionComponent = React.createElement(Vector3Property, {
				FieldName = "Position",

				Value = Vector3.new(components[1], components[2], components[3]),
				OnValueSubmitted = function(p)
					local newComponents = updateComponents({ [1] = p.X, [2] = p.Y, [3] = p.Z })
					setText(toText(newComponents))
				end,

				Indent = indent + 1,
				LayoutOrder = 1,
				Disabled = props.Disabled,
			}),

			OrientationComponent = React.createElement(Vector3Property, {
				FieldName = "Orientation",

				Value = Vector3.new(components[4], components[5], components[6]),
				OnValueSubmitted = function(p)
					local newComponents = updateComponents({ [4] = p.X, [5] = p.Y, [6] = p.Z })
					setText(toText(newComponents))
				end,

				Indent = indent + 1,
				LayoutOrder = 2,
				Disabled = props.Disabled,
			}),
		}),
	})
end

return CFrameProperty
