local uiRoot = script:FindFirstAncestor("UserInterface")
local InputBox = require(uiRoot.Components.Properties.Foundational.InputBox)

local pkgs = uiRoot.Parent.Parent
local StudioComponents = require(pkgs.StudioComponents)
local React = require(pkgs.React)

export type Props = {
	AnchorPoint: Vector2?,
	Position: UDim2?,
	Size: UDim2?,

	FieldName: string,
	HighlightOnCapture: boolean?,

	HSV: { number },
	SetHSV: ({ number }) -> (),

	LayoutOrder: number?,
	Disabled: boolean?,
}

local function NumberInput(props: Props)
	local theme = StudioComponents.useTheme()
	local isHexFocused, setIsHexFocused = React.useState(false)
	local editingEnabledRaw, setEditingEnabled = React.useState(false)

	local editingEnabled = true
	if props.HighlightOnCapture then
		editingEnabled = editingEnabledRaw
	end

	local color = Color3.fromHSV(props.HSV[1], props.HSV[2], props.HSV[3])
	local text, setText = React.useState("#" .. color:ToHex():lower())
	local textBoxRef = React.useRef(nil :: TextBox?)

	React.useEffect(function()
		local newColor = Color3.fromHSV(props.HSV[1], props.HSV[2], props.HSV[3])
		setText("#" .. newColor:ToHex():lower())
	end, { props.HSV })

	return React.createElement("Frame", {
		BackgroundTransparency = 1,
		AnchorPoint = props.AnchorPoint,
		Position = props.Position,
		Size = props.Size,
		LayoutOrder = props.LayoutOrder,
	}, {
		Left = React.createElement("Frame", {
			BackgroundTransparency = 1,
			Size = UDim2.fromScale(1 / 3, 1),
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
			BackgroundTransparency = 1,
			Position = UDim2.fromScale(1 / 3, 0),
			Size = UDim2.fromScale(2 / 3, 1),
		}, {
			UIStroke = React.createElement("UIStroke", {
				Thickness = 1,
				Transparency = 0,
				ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
				BorderStrokePosition = Enum.BorderStrokePosition.Inner,
				LineJoinMode = Enum.LineJoinMode.Miter,
				Color = theme:GetColor(
					Enum.StudioStyleGuideColor.InputFieldBorder,
					if isHexFocused
						then Enum.StudioStyleGuideModifier.Selected
						else Enum.StudioStyleGuideModifier.Default
				),
			}),

			InputFrame = React.createElement("Frame", {
				BackgroundTransparency = 1,
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.fromScale(0.5, 0.5),
				Size = UDim2.new(1, -4, 1, -4),
			}, {
				InputSink = React.createElement("TextBox", {
					BackgroundTransparency = 1,
					Text = "",
					Size = UDim2.fromScale(1, 1),
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

					Text = text,
					OnTextChanged = setText,
					OnTextSubmitted = function(newText)
						setText("#" .. color:ToHex():lower())
						pcall(function()
							local newColor = Color3.fromHex(newText)
							props.SetHSV({ newColor:ToHSV() })
							setText("#" .. newColor:ToHex():lower())
						end)
					end,

					OnFocus = function()
						setIsHexFocused(true)
					end,
					OnFocusLost = function()
						setIsHexFocused(false)
						setEditingEnabled(false)
					end,

					EditingEnabled = true,
					Disabled = props.Disabled,

					ref = textBoxRef,
				}),
			}),
		}),
	})
end

return NumberInput
