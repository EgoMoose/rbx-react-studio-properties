local uiRoot = script:FindFirstAncestor("UserInterface")
local TextSanitizers = require(uiRoot.Helpers.TextSanitizers)

local pkgs = uiRoot.Parent.Parent
local StudioComponents = require(pkgs.StudioComponents)
local React = require(pkgs.React)

local foundationalRoot = script.Parent.Parent.Foundational
local PropertyLine = require(foundationalRoot.PropertyLine)
local InputBox = require(foundationalRoot.InputBox)

export type Props = {
	AnchorPoint: Vector2?,
	Position: UDim2?,

	FieldName: string,
	ForceExpanded: boolean?,

	Value: number,
	OnValueSubmitted: (number) -> ()?,

	Min: number?,
	Max: number?,
	Step: number?,
	Slider: boolean?,

	Indent: number?,
	LayoutOrder: number?,
	ZIndex: number?,
	Disabled: boolean?,

	children: React.ReactNode?,
}

local function NumberProperty(props: Props)
	local isSliderEnabled = props.Min and props.Max and props.Slider

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
	local editingEnabled, setEditingEnabled = React.useState(false)
	local textBoxRef = React.useRef(nil :: TextBox?)

	React.useEffect(function()
		local clampedValue = clampValue(props.Value)
		setNumber(clampedValue)
		setText(tostring(clampedValue))
	end, { props.Value })

	return React.createElement(PropertyLine, {
		AnchorPoint = props.AnchorPoint,
		Position = props.Position,

		FieldName = props.FieldName,
		ForceExpanded = props.ForceExpanded,

		OnFocusLost = function()
			setEditingEnabled(false)
		end,

		OnActivated = function()
			local textBox = textBoxRef.current
			if not editingEnabled and textBox and not textBox:IsFocused() then
				textBox:CaptureFocus()
				textBox.SelectionStart = 1
				textBox.CursorPosition = #textBox.Text + 1
			end

			setEditingEnabled(true)
		end,

		Indent = props.Indent,
		LayoutOrder = props.LayoutOrder,
		ZIndex = props.ZIndex,
		Disabled = props.Disabled,

		Interface = React.createElement(React.Fragment, nil, {
			Input = React.createElement(InputBox, {
				Size = if isSliderEnabled then UDim2.fromScale(1 / 3, 1) else UDim2.fromScale(1, 1),

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
					setEditingEnabled(false)

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

				EditingEnabled = editingEnabled,
				HighlightMode = if isSliderEnabled then "Editing" else "TextboxFocused",

				Disabled = props.Disabled,
				ref = textBoxRef,
			}),
			Slider = isSliderEnabled and editingEnabled and React.createElement(StudioComponents.Slider, {
				AnchorPoint = Vector2.new(0, 0.5),
				Position = UDim2.fromScale(1 / 3, 0.5),
				Size = UDim2.fromScale(2 / 3, 1),
				Min = minValue,
				Max = maxValue,
				Value = number,
				OnChanged = function(value)
					local newValue = clampValue(value)
					setNumber(newValue)
					setText(tostring(newValue))
					if props.OnValueSubmitted then
						props.OnValueSubmitted(newValue)
					end
				end,
				Disabled = props.Disabled,
			}),
		}) :: React.ReactNode,
	}, props.children)
end

return NumberProperty
