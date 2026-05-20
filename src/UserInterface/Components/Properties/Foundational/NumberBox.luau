local uiRoot = script:FindFirstAncestor("UserInterface")
local TextSanitizers = require(uiRoot.Helpers.TextSanitizers)

local pkgs = uiRoot.Parent.Parent
local React = require(pkgs.React)

local InputBox = require(script.Parent.InputBox)

export type Props = {
	AnchorPoint: Vector2?,
	Position: UDim2?,
	Size: UDim2?,

	Value: number,
	OnTextChanged: (string) -> ()?,
	OnValueSubmitted: (number) -> ()?,

	Min: number?,
	Max: number?,
	Step: number?,

	OnFocus: (TextBox) -> ()?,
	OnFocusLost: (TextBox) -> ()?,

	EditingDisabled: boolean?,
	HighlightMode: InputBox.HighlightMode?,

	LayoutOrder: number?,
	ZIndex: number?,
	Disabled: boolean?,
}

local function clampValue(value: number, step: number, minValue: number, maxValue: number)
	if step > 0 then
		-- this function attempts to robustly decimal nudge to avoid
		-- floating point errors when it comes to step flooring
		local nudge = math.abs(value) * 1e-14
		local stepped = math.floor((value / step) + (nudge / step) + 1e-14) * step
		value = math.round(stepped * 10e10) / 10e10
	end
	return math.clamp(value, minValue, maxValue)
end

local function NumberBox(props: Props, ref: React.Ref<TextBox?>?)
	local minValue = props.Min or -math.huge
	local maxValue = props.Max or math.huge

	local step = math.abs(props.Step or 0)
	local isInteger = step > 0 and step % 1 == 0
	local isOnlyPositive = minValue >= 0

	local valueRef = React.useRef(clampValue(props.Value, step, minValue, maxValue))
	local number, setNumber = React.useState(valueRef.current)
	local text, setText = React.useState(tostring(number))

	local setValue = React.useCallback(function(newValue: number, submit: boolean)
		valueRef.current = newValue
		setNumber(newValue)
		setText(tostring(newValue))

		if submit and props.OnValueSubmitted then
			props.OnValueSubmitted(newValue)
		end
	end, { props.OnValueSubmitted })

	React.useEffect(function()
		local newValue = clampValue(props.Value, step, minValue, maxValue)
		if valueRef.current ~= newValue then
			setValue(newValue, false)
		end
	end, { props.Value, setValue } :: { any })

	return React.createElement(InputBox, {
		AnchorPoint = props.AnchorPoint,
		Position = props.Position,
		Size = props.Size,

		OnFocus = props.OnFocus,
		OnFocusLost = props.OnFocusLost,

		Text = text,
		SanitizeText = function(newText, cursor)
			local sanitized = TextSanitizers.numeric(newText, not isOnlyPositive, not isInteger)
			if not (cursor == #newText + 1) and #sanitized ~= #newText then
				cursor = cursor - 1
			end
			return sanitized, cursor
		end,
		OnTextChanged = function(newText)
			setText(newText)
			if props.OnTextChanged then
				props.OnTextChanged(newText)
			end
		end,
		OnTextSubmitted = function(value)
			local newValue = clampValue(tonumber(value) or props.Value, step, minValue, maxValue)
			setValue(newValue, true)
		end,

		OnStepActivated = if step > 0
			then function(direction)
				local currentValue = tonumber(text) or props.Value
				local newValue = clampValue(currentValue + direction * step, step, minValue, maxValue)
				setValue(newValue, true)
			end
			else nil,

		EditingDisabled = props.EditingDisabled,
		HighlightMode = props.HighlightMode,

		LayoutOrder = props.LayoutOrder,
		ZIndex = props.ZIndex,
		Disabled = props.Disabled,

		ref = ref,
	})
end

return React.forwardRef(NumberBox)
