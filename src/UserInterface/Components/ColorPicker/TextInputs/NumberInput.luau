local uiRoot = script:FindFirstAncestor("UserInterface")
local Constants = require(uiRoot.Components.Properties.Foundational.Constants)
local InputBox = require(uiRoot.Components.Properties.Foundational.InputBox)
local TextSanitizers = require(uiRoot.Helpers.TextSanitizers)

local pkgs = uiRoot.Parent.Parent
local StudioComponents = require(pkgs.StudioComponents)
local React = require(pkgs.React)

export type Props = {
	AnchorPoint: Vector2?,
	Position: UDim2?,
	Size: UDim2?,

	FieldName: string,
	HighlightOnCapture: boolean?,

	Value: number,
	OnValueSubmitted: (number) -> ()?,

	Min: number?,
	Max: number?,
	Step: number?,

	LayoutOrder: number?,
	Disabled: boolean?,
}

local function NumberInput(props: Props)
	local theme = StudioComponents.useTheme()
	local editingEnabledRaw, setEditingEnabled = React.useState(false)
	local textBoxRef = React.useRef(nil :: TextBox?)

	local editingEnabled = true
	if props.HighlightOnCapture then
		editingEnabled = editingEnabledRaw
	end

	local minValue = props.Min or -math.huge
	local maxValue = props.Max or math.huge

	local step = math.abs(props.Step or 0)
	local isInteger = step > 0 and step % 1 == 0
	local isOnlyPositive = minValue >= 0

	local function clampValue(value: number)
		if step > 0 then
			-- this function attempts to robustly decimal nudge to avoid
			-- floating point errors when it comes to step flooring
			local nudge = math.abs(value) * 1e-14
			local stepped = math.floor((value / step) + (nudge / step) + 1e-14) * step
			value = math.round(stepped * 10e10) / 10e10
		end
		return math.clamp(value, minValue, maxValue)
	end

	local number, setNumber = React.useState(clampValue(props.Value))
	local text, setText = React.useState(tostring(number))

	React.useEffect(function()
		local clampedValue = clampValue(props.Value)
		setNumber(clampedValue)
		setText(tostring(clampedValue))
	end, { props.Value })

	return React.createElement("Frame", {
		BackgroundTransparency = 1,
		AnchorPoint = props.AnchorPoint,
		Position = props.Position,
		Size = props.Size,
		LayoutOrder = props.LayoutOrder,
	}, {
		Left = React.createElement("Frame", {
			BackgroundTransparency = 1,
			Size = UDim2.fromScale(0.5, 1),
		}, {
			UIPadding = React.createElement("UIPadding", {
				PaddingLeft = UDim.new(0, 4),
				PaddingRight = UDim.new(0, 4),
			}),
			Label = React.createElement("TextLabel", {
				BackgroundTransparency = 1,
				Size = UDim2.fromScale(1, 1),
				FontFace = Font.fromName("SourceSansPro"),
				TextYAlignment = Enum.TextYAlignment.Center,
				TextXAlignment = Enum.TextXAlignment.Right,
				TextTruncate = Enum.TextTruncate.AtEnd,
				TextColor3 = theme:GetColor(
					Enum.StudioStyleGuideColor.MainText,
					if props.Disabled then Enum.StudioStyleGuideModifier.Disabled else nil
				),
				Text = props.FieldName,
				TextSize = 14,
			}),
		}),
		Right = React.createElement("Frame", {
			BackgroundColor3 = theme:GetColor(Enum.StudioStyleGuideColor.MainBackground),
			BorderColor3 = theme:GetColor(Enum.StudioStyleGuideColor.Border),
			Position = UDim2.fromScale(0.5, 0),
			Size = UDim2.fromScale(0.5, 1),
		}, {
			InputSink = React.createElement("TextBox", {
				BackgroundTransparency = 1,
				Text = "",
				Size = UDim2.new(1, -Constants.LineHeight, 1, 0),
				Visible = not editingEnabled,
				ZIndex = 2,

				[React.Event.Focused] = function()
					local textBox = textBoxRef.current
					if not editingEnabled and textBox and not textBox:IsFocused() then
						textBox:CaptureFocus()
						textBox.SelectionStart = 1
						textBox.CursorPosition = #textBox.Text + 1
					end

					setEditingEnabled(true)
				end,
			}),

			Input = React.createElement(InputBox, {
				Size = UDim2.fromScale(1, 1),

				OnFocusLost = function()
					setEditingEnabled(false)
				end,

				Text = text,
				SanitizeText = function(newText, cursor)
					local sanitized = TextSanitizers.numeric(newText, not isOnlyPositive, not isInteger)
					if not (cursor == #newText + 1) and #sanitized ~= #newText then
						cursor = cursor - 1
					end
					return sanitized, cursor
				end,

				OnTextChanged = setText,
				OnTextSubmitted = function(value)
					local newValue = clampValue(tonumber(value) or props.Value)
					setNumber(newValue)
					setText(tostring(newValue))

					if props.OnValueSubmitted then
						props.OnValueSubmitted(newValue)
					end
				end,

				OnStepActivated = if step > 0
					then function(direction)
						local currentValue = tonumber(text) or props.Value
						local newValue = clampValue(currentValue + direction * step)

						setNumber(newValue)
						setText(tostring(newValue))

						if props.OnValueSubmitted then
							props.OnValueSubmitted(newValue)
						end
					end
					else nil,

				EditingEnabled = true,
				HighlightMode = "TextboxFocused",
				Disabled = props.Disabled,

				ref = textBoxRef,
			}),
		}),
	})
end

return NumberInput
