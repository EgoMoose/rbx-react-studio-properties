local uiRoot = script:FindFirstAncestor("UserInterface")
local pkgs = uiRoot.Parent.Parent
local React = require(pkgs.React)

local InputBox = require(script.Parent.InputBox)

export type Props = {
	BackgroundTransparency: number?,
	BackgroundColor3: Color3?,
	BorderSizePixel: number?,

	AnchorPoint: Vector2?,
	Position: UDim2?,
	Size: UDim2?,

	Value: string,
	OnTextChanged: (string) -> ()?,
	OnValueSubmitted: (string) -> ()?,

	OnFocus: (TextBox) -> ()?,
	OnFocusLost: (TextBox) -> ()?,
	HighlightOnFocus: boolean?,

	EditingDisabled: boolean?,
	HighlightMode: InputBox.HighlightMode?,

	LayoutOrder: number?,
	ZIndex: number?,
	Disabled: boolean?,
}

local function StringBox(props: Props, ref: React.Ref<TextBox?>?)
	local valueRef = React.useRef(props.Value)
	local text, setText = React.useState(valueRef.current)

	local setValue = React.useCallback(function(newValue: string, submit: boolean)
		valueRef.current = newValue
		setText(newValue)

		if submit and props.OnValueSubmitted then
			props.OnValueSubmitted(newValue)
		end
	end, { props.OnValueSubmitted })

	React.useEffect(function()
		if valueRef.current ~= props.Value then
			setValue(props.Value, false)
		end
	end, { props.Value, setValue } :: { any })

	return React.createElement(InputBox, {
		BackgroundTransparency = props.BackgroundTransparency,
		BackgroundColor3 = props.BackgroundColor3,
		BorderSizePixel = props.BorderSizePixel,

		AnchorPoint = props.AnchorPoint,
		Position = props.Position,
		Size = props.Size,

		OnFocus = props.OnFocus,
		OnFocusLost = props.OnFocusLost,
		HighlightOnFocus = props.HighlightOnFocus,

		Text = text,
		OnTextSubmitted = props.OnValueSubmitted,
		OnTextChanged = function(newText)
			setText(newText)
			if props.OnTextChanged then
				props.OnTextChanged(newText)
			end
		end,

		EditingDisabled = props.EditingDisabled,
		HighlightMode = props.HighlightMode,

		LayoutOrder = props.LayoutOrder,
		ZIndex = props.ZIndex,
		Disabled = props.Disabled,

		ref = ref,
	})
end

return React.forwardRef(StringBox)
