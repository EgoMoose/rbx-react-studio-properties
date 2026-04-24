local pkgs = script:FindFirstAncestor("UserInterface").Parent.Parent
local React = require(pkgs.React)

local HueSaturationPicker = require(script.HueSaturationPicker)
local ValuePicker = require(script.ValuePicker)

export type Props = {
	AnchorPoint: Vector2?,
	Position: UDim2?,
	Size: UDim2?,

	HSV: { number },
	SetHSV: ({ number }) -> (),

	Disabled: boolean?,
}

local function HSVPicker(props: Props)
	return React.createElement("Frame", {
		BackgroundTransparency = 1,
		AnchorPoint = props.AnchorPoint,
		Position = props.Position,
		Size = props.Size,
	}, {
		HSPicker = React.createElement(HueSaturationPicker, {
			Size = UDim2.new(0, 220, 1, 0),

			HSV = props.HSV,
			OnChanged = function(h, s)
				local copy = table.clone(props.HSV)
				copy[1] = h
				copy[2] = s
				props.SetHSV(copy)
			end,

			Disabled = props.Disabled,
		}),

		VPicker = React.createElement(ValuePicker, {
			AnchorPoint = Vector2.new(1, 0),
			Position = UDim2.new(1, -12, 0, 0),
			Size = UDim2.new(0, 14, 1, 0),

			HSV = props.HSV,
			OnChanged = function(v)
				local copy = table.clone(props.HSV)
				copy[3] = v
				props.SetHSV(copy)
			end,

			Disabled = props.Disabled,
		}),
	})
end

return HSVPicker
