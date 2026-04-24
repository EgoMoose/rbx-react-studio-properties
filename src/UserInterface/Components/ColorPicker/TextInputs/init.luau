local pkgs = script:FindFirstAncestor("UserInterface").Parent.Parent
local React = require(pkgs.React)

local NumberInput = require(script.NumberInput)
local HexInput = require(script.HexInput)

local HIGHLIGHT_ON_CAPTURE = true

export type Props = {
	AnchorPoint: Vector2?,
	Position: UDim2?,
	Size: UDim2?,

	HSV: { number },
	SetHSV: ({ number }) -> (),

	Disabled: boolean?,
}

local function TextInputs(props: Props)
	local color = Color3.fromHSV(props.HSV[1], props.HSV[2], props.HSV[3])
	local hex = color:ToHex()

	local r255 = tonumber(hex:sub(1, 2), 16) or 0
	local g255 = tonumber(hex:sub(3, 4), 16) or 0
	local b255 = tonumber(hex:sub(5, 6), 16) or 0

	return React.createElement("Frame", {
		BackgroundTransparency = 1,
		AnchorPoint = props.AnchorPoint,
		Position = props.Position,
		Size = props.Size,
	}, {
		Left = React.createElement("Frame", {
			BackgroundTransparency = 1,
			Size = UDim2.fromScale(0.5, 1),
		}, {
			UIListLayout = React.createElement("UIListLayout", {
				FillDirection = Enum.FillDirection.Vertical,
				SortOrder = Enum.SortOrder.LayoutOrder,
				Padding = UDim.new(0, 5),
			}),

			HueInput = React.createElement(NumberInput, {
				Size = UDim2.new(1, 0, 0, 22),

				FieldName = "Hue:",
				HighlightOnCapture = HIGHLIGHT_ON_CAPTURE,

				Max = 255,
				Min = 0,
				Step = 1,

				Value = math.floor(props.HSV[1] * 255),
				OnValueSubmitted = function(h255)
					local copy = table.clone(props.HSV)
					copy[1] = h255 / 255
					props.SetHSV(copy)
				end,

				Disabled = props.Disabled,
				LayoutOrder = 1,
			}),

			SaturationInput = React.createElement(NumberInput, {
				Size = UDim2.new(1, 0, 0, 22),

				FieldName = "Sat:",
				HighlightOnCapture = HIGHLIGHT_ON_CAPTURE,

				Max = 255,
				Min = 0,
				Step = 1,

				Value = math.floor(props.HSV[2] * 255),
				OnValueSubmitted = function(s255)
					local copy = table.clone(props.HSV)
					copy[2] = s255 / 255
					props.SetHSV(copy)
				end,

				Disabled = props.Disabled,
				LayoutOrder = 2,
			}),

			ValueInput = React.createElement(NumberInput, {
				Size = UDim2.new(1, 0, 0, 22),

				FieldName = "Val:",
				HighlightOnCapture = HIGHLIGHT_ON_CAPTURE,

				Max = 255,
				Min = 0,
				Step = 1,

				Value = math.floor(props.HSV[3] * 255),
				OnValueSubmitted = function(v255)
					local copy = table.clone(props.HSV)
					copy[3] = v255 / 255
					props.SetHSV(copy)
				end,

				Disabled = props.Disabled,
				LayoutOrder = 3,
			}),
		}),

		Right = React.createElement("Frame", {
			BackgroundTransparency = 1,
			Position = UDim2.fromScale(0.5, 0),
			Size = UDim2.fromScale(0.5, 1),
		}, {
			UIListLayout = React.createElement("UIListLayout", {
				FillDirection = Enum.FillDirection.Vertical,
				SortOrder = Enum.SortOrder.LayoutOrder,
				Padding = UDim.new(0, 5),
			}),

			RedInput = React.createElement(NumberInput, {
				Size = UDim2.new(1, 0, 0, 22),

				FieldName = "Red:",
				HighlightOnCapture = HIGHLIGHT_ON_CAPTURE,

				Max = 255,
				Min = 0,
				Step = 1,

				Value = r255,
				OnValueSubmitted = function(new255)
					props.SetHSV({ Color3.fromRGB(new255, g255, b255):ToHSV() })
				end,

				Disabled = props.Disabled,
				LayoutOrder = 1,
			}),

			GreenInput = React.createElement(NumberInput, {
				Size = UDim2.new(1, 0, 0, 22),

				FieldName = "Green:",
				HighlightOnCapture = HIGHLIGHT_ON_CAPTURE,

				Max = 255,
				Min = 0,
				Step = 1,

				Value = g255,
				OnValueSubmitted = function(new255)
					props.SetHSV({ Color3.fromRGB(r255, new255, b255):ToHSV() })
				end,

				Disabled = props.Disabled,
				LayoutOrder = 2,
			}),

			BlueInput = React.createElement(NumberInput, {
				Size = UDim2.new(1, 0, 0, 22),

				FieldName = "Blue:",
				HighlightOnCapture = HIGHLIGHT_ON_CAPTURE,

				Max = 255,
				Min = 0,
				Step = 1,

				Value = b255,
				OnValueSubmitted = function(new255)
					props.SetHSV({ Color3.fromRGB(r255, g255, new255):ToHSV() })
				end,

				Disabled = props.Disabled,
				LayoutOrder = 3,
			}),
		}),

		HexInput = React.createElement(HexInput, {
			AnchorPoint = Vector2.new(0, 1),
			Position = UDim2.fromScale(0, 1),
			Size = UDim2.new(0.75, 0, 0, 24),

			FieldName = "Hex:",
			HighlightOnCapture = HIGHLIGHT_ON_CAPTURE,

			HSV = props.HSV,
			SetHSV = props.SetHSV,

			Disabled = props.Disabled,
		}),
	})
end

return TextInputs
