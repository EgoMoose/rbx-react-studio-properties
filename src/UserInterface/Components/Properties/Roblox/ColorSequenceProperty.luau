local UserInputService = game:GetService("UserInputService")

local uiRoot = script:FindFirstAncestor("UserInterface")
local useColorSequencePickerDock = require(uiRoot.Hooks.useColorSequencePickerDock)
local useColorPickerDock = require(uiRoot.Hooks.useColorPickerDock)
local ColorSequencePicker = require(uiRoot.Components.ColorSequencePicker)
local ColorPicker = require(uiRoot.Components.ColorPicker)

local pkgs = uiRoot.Parent.Parent
local StudioComponents = require(pkgs.StudioComponents)
local ReactRoblox = require(pkgs.ReactRoblox)
local React = require(pkgs.React)

local foundationalRoot = script.Parent.Parent.Foundational
local PropertyLine = require(foundationalRoot.PropertyLine)
local Constants = require(foundationalRoot.Constants)
local InputBox = require(foundationalRoot.InputBox)

local MORE_BUTTON_WIDTH = 28
local MORE_BUTTON_GAP = 4
local NON_CONSTANT_TEXT = "<ColorSequence>"

export type Props = {
	AnchorPoint: Vector2?,
	Position: UDim2?,

	FieldName: string,

	Value: ColorSequence,
	OnValueSubmitted: (ColorSequence) -> ()?,

	Indent: number?,
	LayoutOrder: number?,
	ZIndex: number?,
	Disabled: boolean?,
}

local function getConstantColor(value: ColorSequence): Color3?
	local keypoints = value.Keypoints
	local first = keypoints[1].Value
	for i = 2, #keypoints do
		if keypoints[i].Value ~= first then
			return nil
		end
	end
	return first
end

local function toText(value: ColorSequence)
	local color = getConstantColor(value)
	if not color then
		return NON_CONSTANT_TEXT
	end

	local hex = color:ToHex()
	local r255 = tonumber(hex:sub(1, 2), 16) or 0
	local g255 = tonumber(hex:sub(3, 4), 16) or 0
	local b255 = tonumber(hex:sub(5, 6), 16) or 0
	return `{r255}, {g255}, {b255}`
end

local function fromText(text: string): ColorSequence?
	local splitByComma = text:split(",")

	if #splitByComma == 1 then
		local component = tonumber(splitByComma[1])
		if component then
			local c = math.clamp(math.floor(component), 0, 255)
			return ColorSequence.new(Color3.fromRGB(c, c, c))
		end
		return nil
	end

	local components = {}
	for i = 1, 3 do
		local component = tonumber(splitByComma[i])
		if not component then
			return nil
		end
		components[i] = math.clamp(math.floor(component), 0, 255)
	end

	return ColorSequence.new(Color3.fromRGB(components[1], components[2], components[3]))
end

local function ColorSequenceProperty(props: Props)
	local theme = StudioComponents.useTheme()
	local isOpen, dock, setDockEnabled = useColorSequencePickerDock()
	local isColorOpen, colorDock, setColorDockEnabled = useColorPickerDock()
	local disabled = props.Disabled or (dock and dock.Enabled) or (colorDock and colorDock.Enabled)

	local prevValueRef = React.useRef(props.Value)
	local pickingColorRef = React.useRef(false)

	local text, setText = React.useState(toText(props.Value))
	local editingEnabled, setEditingEnabled = React.useState(false)
	local textBoxRef = React.useRef(nil :: TextBox?)

	local textFocused, setTextFocused = React.useState(false)
	local textFocusedRef = React.useRef(false)

	local hoveringButtonRef = React.useRef(false)
	local hoveringSwatchRef = React.useRef(false)
	local moreButtonHovered, setMoreButtonHovered = React.useState(false)
	local swatchHovered, setSwatchHovered = React.useState(false)

	local swatchArmedRef = React.useRef(false)
	local swatchIsButton = textFocused and not disabled

	React.useEffect(function()
		setText(toText(props.Value))
	end, { props.Value })

	React.useEffect(function()
		if not isColorOpen and pickingColorRef.current then
			pickingColorRef.current = false
			if props.Value ~= prevValueRef.current and props.OnValueSubmitted then
				props.OnValueSubmitted(prevValueRef.current)
			end
		end
	end, { isColorOpen })

	return React.createElement(PropertyLine, {
		AnchorPoint = props.AnchorPoint,
		Position = props.Position,

		FieldName = props.FieldName,

		OnFocusLost = function()
			setEditingEnabled(false)
		end,

		OnActivated = function()
			local pressingSwatch = hoveringSwatchRef.current
				and (swatchArmedRef.current or textFocusedRef.current)
				and not disabled
			if not (hoveringButtonRef.current or pressingSwatch) then
				local textBox = textBoxRef.current
				if textBox and not textBox:IsFocused() then
					textBox:CaptureFocus()
					if not editingEnabled then
						textBox.SelectionStart = 1
						textBox.CursorPosition = #textBox.Text + 1
					end
				end

				setEditingEnabled(true)
			end
		end,

		Indent = props.Indent,
		LayoutOrder = props.LayoutOrder,
		ZIndex = props.ZIndex,
		Disabled = disabled,

		Interface = React.createElement(React.Fragment, nil, {
			Content = React.createElement("Frame", {
				BackgroundTransparency = 1,
				Size = UDim2.fromScale(1, 1),
			}, {
				Swatch = React.createElement("ImageButton", {
					AnchorPoint = Vector2.new(0, 0.5),
					Position = UDim2.fromScale(0, 0.5),
					Size = UDim2.new(0, Constants.LineHeight, 1, -2),
					BorderMode = Enum.BorderMode.Inset,
					BorderSizePixel = if swatchIsButton then 1 else 0,
					BorderColor3 = theme:GetColor(Enum.StudioStyleGuideColor.ButtonBorder),
					BackgroundTransparency = if swatchIsButton then 0 else 1,
					BackgroundColor3 = theme:GetColor(
						Enum.StudioStyleGuideColor.Button,
						if swatchHovered then Enum.StudioStyleGuideModifier.Hover else nil
					),
					AutoButtonColor = false,
					Image = "",

					[React.Event.InputBegan] = function(_, input: InputObject)
						if
							input.UserInputType == Enum.UserInputType.MouseButton1
							and textFocusedRef.current
							and not disabled
						then
							swatchArmedRef.current = true
						end
					end,

					[React.Event.Activated] = function()
						local armed = swatchArmedRef.current
						swatchArmedRef.current = false
						if armed and colorDock then
							prevValueRef.current = props.Value
							pickingColorRef.current = true
							hoveringSwatchRef.current = false
							setSwatchHovered(false)
							setEditingEnabled(false)
							setColorDockEnabled(true)
						end
					end,

					[React.Event.MouseEnter] = function()
						hoveringSwatchRef.current = true
						setSwatchHovered(true)
					end,
					[React.Event.MouseLeave] = function()
						hoveringSwatchRef.current = false
						swatchArmedRef.current = false
						setSwatchHovered(false)
					end,
				}, {
					Preview = React.createElement("Frame", {
						AnchorPoint = Vector2.new(0.5, 0.5),
						Position = UDim2.fromScale(0.5, 0.5),
						Size = UDim2.fromOffset(Constants.LineHeight - 10, Constants.LineHeight - 10),
						BorderColor3 = Color3.new(0, 0, 0),
						BackgroundColor3 = Color3.new(1, 1, 1),
					}, {
						UIGradient = React.createElement("UIGradient", {
							Color = props.Value,
						}),
					}),
					DisabledOverlay = props.Disabled and React.createElement("Frame", {
						AnchorPoint = Vector2.new(0.5, 0.5),
						Position = UDim2.fromScale(0.5, 0.5),
						Size = UDim2.fromOffset(Constants.LineHeight - 10, Constants.LineHeight - 10),
						BorderSizePixel = 0,
						BackgroundTransparency = 0.5,
						BackgroundColor3 = theme:GetColor(
							Enum.StudioStyleGuideColor.ButtonText,
							Enum.StudioStyleGuideModifier.Disabled
						),
					}),
				}),

				Input = React.createElement(InputBox, {
					Position = UDim2.fromOffset(Constants.LineHeight, 0),
					Size = UDim2.new(
						1,
						-Constants.LineHeight - (if editingEnabled then MORE_BUTTON_WIDTH + MORE_BUTTON_GAP else 0),
						1,
						0
					),
					BorderSizePixel = if editingEnabled then 1 else 0,

					Text = if editingEnabled or text == NON_CONSTANT_TEXT then text else `[{text}]`,
					OnFocus = function()
						textFocusedRef.current = true
						setTextFocused(true)
					end,
					OnFocusLost = function()
						if
							hoveringSwatchRef.current
							and not disabled
							and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1)
						then
							swatchArmedRef.current = true
						end
						textFocusedRef.current = false
						setTextFocused(false)
					end,

					OnTextChanged = setText,
					OnTextSubmitted = function(newText)
						local newValue = fromText(newText)

						setEditingEnabled(false)
						if newValue and newValue ~= props.Value then
							setText(toText(newValue))
							if props.OnValueSubmitted then
								props.OnValueSubmitted(newValue)
							end
						else
							setText(toText(props.Value))
						end
					end,

					EditingDisabled = not editingEnabled,
					HighlightMode = "TextboxFocused",

					Disabled = disabled,
					ref = textBoxRef,
				}),

				MoreButton = editingEnabled
					and React.createElement("TextButton", {
						AnchorPoint = Vector2.new(1, 0.5),
						Position = UDim2.new(1, -1, 0.5, 0),
						Size = UDim2.new(0, MORE_BUTTON_WIDTH, 1, -2),
						BorderMode = Enum.BorderMode.Inset,
						AutoButtonColor = false,
						BorderColor3 = theme:GetColor(Enum.StudioStyleGuideColor.ButtonBorder),
						BackgroundColor3 = theme:GetColor(
							Enum.StudioStyleGuideColor.Button,
							if moreButtonHovered then Enum.StudioStyleGuideModifier.Hover else nil
						),
						FontFace = Font.fromName("SourceSansPro"),
						TextColor3 = theme:GetColor(Enum.StudioStyleGuideColor.ButtonText),
						Text = "...",
						TextSize = 14,

						[React.Event.InputBegan] = function(_, input: InputObject)
							if input.UserInputType == Enum.UserInputType.MouseButton1 and not disabled and dock then
								hoveringButtonRef.current = false
								setMoreButtonHovered(false)
								setEditingEnabled(false)
								setDockEnabled(true)
							end
						end,

						[React.Event.MouseEnter] = function()
							hoveringButtonRef.current = true
							setMoreButtonHovered(true)
						end,
						[React.Event.MouseLeave] = function()
							hoveringButtonRef.current = false
							setMoreButtonHovered(false)
						end,
					}),
			}),

			ColorPicker = isColorOpen and colorDock and ReactRoblox.createPortal(
				React.createElement(ColorPicker, {
					AnchorPoint = Vector2.new(0.5, 0.5),
					Position = UDim2.fromScale(0.5, 0.5),
					Size = UDim2.fromScale(1, 1),

					Value = prevValueRef.current.Keypoints[1].Value,
					OnValueChanged = function(newColor)
						if props.OnValueSubmitted then
							props.OnValueSubmitted(ColorSequence.new(newColor))
						end
					end,
					OnValueSubmitted = function(newColor)
						pickingColorRef.current = false
						if props.OnValueSubmitted then
							props.OnValueSubmitted(
								if newColor then ColorSequence.new(newColor) else prevValueRef.current
							)
						end
						setColorDockEnabled(false)
					end,

					Disabled = false,
				}),
				colorDock
			),

			ColorSequencePicker = isOpen and dock and ReactRoblox.createPortal(
				React.createElement(ColorSequencePicker, {
					AnchorPoint = Vector2.new(0.5, 0.5),
					Position = UDim2.fromScale(0.5, 0.5),
					Size = UDim2.fromScale(1, 1),

					Value = props.Value,
					OnValueChanged = function(newValue)
						if props.OnValueSubmitted then
							props.OnValueSubmitted(newValue)
						end
					end,
					OnValueSubmitted = function()
						setDockEnabled(false)
					end,

					Disabled = false,
				}),
				dock
			),
		}) :: React.ReactNode,
	})
end

return ColorSequenceProperty
