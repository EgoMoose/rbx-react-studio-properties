local uiRoot = script:FindFirstAncestor("UserInterface")
local useColorPickerDock = require(uiRoot.Hooks.useColorPickerDock)
local ColorPicker = require(uiRoot.Components.ColorPicker)

local pkgs = uiRoot.Parent.Parent
local StudioComponents = require(pkgs.StudioComponents)
local ReactRoblox = require(pkgs.ReactRoblox)
local React = require(pkgs.React)

local foundationalRoot = script.Parent.Parent.Foundational
local PropertyLine = require(foundationalRoot.PropertyLine)
local Constants = require(foundationalRoot.Constants)
local InputBox = require(foundationalRoot.InputBox)

export type Props = {
	AnchorPoint: Vector2?,
	Position: UDim2?,

	FieldName: string,

	Value: Color3,
	OnValueSubmitted: (Color3) -> ()?,

	Indent: number?,
	LayoutOrder: number?,
	ZIndex: number?,
	Disabled: boolean?,
}

local function toArray(value: Color3)
	local hex = value:ToHex()
	local r255 = tonumber(hex:sub(1, 2), 16) or 0
	local g255 = tonumber(hex:sub(3, 4), 16) or 0
	local b255 = tonumber(hex:sub(5, 6), 16) or 0
	return { r255, g255, b255 }
end

local function fromArray(components: { number })
	return Color3.fromRGB(components[1], components[2], components[3])
end

local function toText(components: { number })
	return table.concat(components, ", ")
end

local function Color3Property(props: Props)
	local theme = StudioComponents.useTheme()
	local isOpen, dock, setDockEnabled = useColorPickerDock()
	local disabled = props.Disabled or (dock and dock.Enabled)
	local prevColor = React.useRef(props.Value)

	local text, setText = React.useState(toText(toArray(props.Value)))
	local editingEnabled, setEditingEnabled = React.useState(false)
	local textBoxRef = React.useRef(nil :: TextBox?)

	local hoveringSwatchRef = React.useRef(false)

	React.useEffect(function()
		setText(toText(toArray(props.Value)))
	end, { props.Value })

	React.useEffect(function()
		if not isOpen and props.Value ~= prevColor.current and props.OnValueSubmitted then
			props.OnValueSubmitted(prevColor.current)
		end
	end, { isOpen })

	return React.createElement(PropertyLine, {
		AnchorPoint = props.AnchorPoint,
		Position = props.Position,

		FieldName = props.FieldName,

		OnFocusLost = function()
			setEditingEnabled(false)
		end,

		OnActivated = function()
			if not hoveringSwatchRef.current then
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
				Swatch = React.createElement("Frame", {
					BackgroundTransparency = 1,
					Size = UDim2.new(0, Constants.LineHeight, 1, 0),
				}, {
					Button = React.createElement("ImageButton", {
						AnchorPoint = Vector2.new(0.5, 0.5),
						Position = UDim2.fromScale(0.5, 0.5),
						Size = UDim2.new(1, -10, 1, -10),
						BorderColor3 = Color3.new(0, 0, 0),
						BackgroundColor3 = props.Value,
						AutoButtonColor = not disabled,
						Image = "",

						[React.Event.Activated] = function()
							if not disabled then
								prevColor.current = props.Value
								setEditingEnabled(false)
								setDockEnabled(true)
							end
						end,

						[React.Event.MouseEnter] = function()
							hoveringSwatchRef.current = true
						end,
						[React.Event.MouseLeave] = function()
							hoveringSwatchRef.current = false
						end,
					}, {
						DisabledOverlay = props.Disabled and React.createElement("Frame", {
							BorderSizePixel = 0,
							BackgroundTransparency = 0.5,
							BackgroundColor3 = theme:GetColor(
								Enum.StudioStyleGuideColor.ButtonText,
								Enum.StudioStyleGuideModifier.Disabled
							),
							Size = UDim2.fromScale(1, 1),
						}),
					}),
				}),

				Input = React.createElement(InputBox, {
					Position = UDim2.fromOffset(Constants.LineHeight, 0),
					Size = UDim2.new(1, -Constants.LineHeight, 1, 0),

					Text = if editingEnabled then text else `[{text}]`,
					OnTextChanged = setText,
					OnTextSubmitted = function(newText)
						local newComponents = {}
						local splitByComma = newText:split(",")
						for i = 1, 3 do
							newComponents[i] = math.clamp(math.floor(tonumber(splitByComma[i]) or 0), 0, 255)
						end

						setText(toText(newComponents))
						setEditingEnabled(false)
						if props.OnValueSubmitted then
							props.OnValueSubmitted(fromArray(newComponents))
						end
					end,

					EditingEnabled = editingEnabled,
					HighlightMode = "TextboxFocused",

					Disabled = disabled,
					ref = textBoxRef,
				}),
			}),

			ColorPicker = isOpen and dock and ReactRoblox.createPortal(
				React.createElement(ColorPicker, {
					AnchorPoint = Vector2.new(0.5, 0.5),
					Position = UDim2.fromScale(0.5, 0.5),
					Size = UDim2.fromScale(1, 1),

					Value = props.Value,
					OnValueChanged = function(newColor)
						if props.OnValueSubmitted then
							props.OnValueSubmitted(newColor)
						end
					end,
					OnValueSubmitted = function(newColor)
						if props.OnValueSubmitted then
							prevColor.current = newColor or prevColor.current
							props.OnValueSubmitted(prevColor.current)
						end
						setDockEnabled(false)
					end,

					Disabled = false,
				}),
				dock
			),
		}) :: React.ReactNode,
	})
end

return Color3Property
