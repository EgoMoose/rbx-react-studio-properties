local uiRoot = script:FindFirstAncestor("UserInterface")
local Constants = require(script.Parent.Constants)
local Assets = require(uiRoot.Assets)

local pkgs = uiRoot.Parent.Parent
local StudioComponents = require(pkgs.StudioComponents)
local React = require(pkgs.React)

export type Props = {
	AnchorPoint: Vector2?,
	Position: UDim2?,
	Size: UDim2?,

	OnFocus: (TextBox) -> ()?,
	OnFocusLost: (TextBox) -> ()?,

	Text: string,
	OnTextChanged: (string) -> ()?,
	OnTextSubmitted: (string) -> ()?,
	SanitizeText: ((string, number) -> (string, number?))?,

	OnStepActivated: (number) -> ()?,

	EditingEnabled: boolean,
	HighlightMode: ("Editing" | "TextboxFocused")?,

	LayoutOrder: number?,
	ZIndex: number?,
	Disabled: boolean?,
}

local function InputBox(props: Props, ref: React.Ref<TextBox?>?)
	local isEditing = props.EditingEnabled and not props.Disabled

	local theme = StudioComponents.useTheme()
	local isFocused, setIsFocused = React.useState(false)

	local textBoxRef = React.useRef(nil :: TextBox?)

	local highlightEnabled = false
	if props.HighlightMode == "Editing" then
		highlightEnabled = true
	elseif props.HighlightMode == "TextboxFocused" then
		highlightEnabled = isFocused
	end

	return React.createElement("Frame", {
		BackgroundTransparency = 1,
		AnchorPoint = props.AnchorPoint,
		Position = props.Position,
		Size = props.Size,
		LayoutOrder = props.LayoutOrder,
		ZIndex = props.ZIndex,
	}, {
		InputFrame = React.createElement("Frame", {
			Visible = isEditing,
			BackgroundTransparency = 1,
			Size = UDim2.fromScale(1, 1),
		}, {
			TextBox = React.createElement("TextBox", {
				ClipsDescendants = true,

				BorderSizePixel = 0,
				BackgroundColor3 = theme:GetColor(
					Enum.StudioStyleGuideColor.InputFieldBackground,
					Enum.StudioStyleGuideModifier.Selected
				),

				Size = if props.OnStepActivated
					then UDim2.new(1, -Constants.LineHeight, 1, 0)
					else UDim2.fromScale(1, 1),
				FontFace = Font.fromName("SourceSansPro"),
				TextYAlignment = Enum.TextYAlignment.Center,
				TextXAlignment = Enum.TextXAlignment.Left,
				TextColor3 = theme:GetColor(
					Enum.StudioStyleGuideColor.MainText,
					if props.Disabled then Enum.StudioStyleGuideModifier.Disabled else nil
				),
				Text = props.Text,
				TextSize = 14,
				ClearTextOnFocus = false,

				[React.Change.Text] = function(rbx: TextBox)
					local cursorPosition
					local newText = rbx.Text
					if props.SanitizeText then
						newText, cursorPosition = props.SanitizeText(newText, rbx.CursorPosition)
					end

					rbx.Text = newText
					if cursorPosition then
						rbx.CursorPosition = cursorPosition
					end

					if newText ~= props.Text and props.OnTextChanged then
						props.OnTextChanged(newText)
					end
				end,

				[React.Event.Focused] = function(rbx: TextBox)
					setIsFocused(true)
					if props.OnFocus then
						props.OnFocus(rbx)
					end
				end,

				[React.Event.FocusLost] = function(rbx: TextBox)
					setIsFocused(false)
					if props.OnFocusLost then
						props.OnFocusLost(rbx)
					end

					local newText = rbx.Text
					if props.SanitizeText then
						newText = props.SanitizeText(newText, rbx.CursorPosition)
					end

					rbx.Text = newText

					if props.OnTextSubmitted then
						props.OnTextSubmitted(newText)
					end
				end,

				ref = function(instance)
					local castedRef = ref :: { current: TextBox? }?
					if castedRef then
						castedRef.current = instance
					end
					textBoxRef.current = instance
				end,
			}, {
				UIPadding = React.createElement("UIPadding", {
					PaddingLeft = UDim.new(0, 4),
					PaddingRight = UDim.new(0, 4),
				}),
			}),

			StepButtons = props.OnStepActivated and React.createElement("Frame", {
				BackgroundTransparency = 1,
				AnchorPoint = Vector2.new(1, 0),
				Position = UDim2.fromScale(1, 0),
				Size = UDim2.new(0, Constants.LineHeight, 1, 0),
			}, {
				UpButton = React.createElement("ImageButton", {
					BorderSizePixel = 0,
					BackgroundColor3 = theme:GetColor(
						Enum.StudioStyleGuideColor.InputFieldBackground,
						Enum.StudioStyleGuideModifier.Selected
					),
					Size = UDim2.new(1, 0, 0.5, 0),

					[React.Event.Activated] = function()
						props.OnStepActivated(1)
					end,
				}, {
					Icon = React.createElement("ImageLabel", {
						BackgroundTransparency = 1,
						AnchorPoint = Vector2.new(0.5, 0.5),
						Position = UDim2.new(0.5, 0, 0.5, 0),
						Size = UDim2.fromOffset(12, 12),
						Image = Assets.ArrowsSpriteSheet,
						ImageRectSize = Vector2.new(16, 16),
						ImageRectOffset = Vector2.new(0, 0),
						ImageColor3 = theme:GetColor(Enum.StudioStyleGuideColor.ButtonText),
					}),
				}),
				DownButton = React.createElement("ImageButton", {
					BorderSizePixel = 0,
					BackgroundColor3 = theme:GetColor(
						Enum.StudioStyleGuideColor.InputFieldBackground,
						Enum.StudioStyleGuideModifier.Selected
					),
					Size = UDim2.new(1, 0, 0.5, 0),
					Position = UDim2.fromScale(0, 0.5),

					[React.Event.Activated] = function()
						props.OnStepActivated(-1)
					end,
				}, {
					Icon = React.createElement("ImageLabel", {
						BackgroundTransparency = 1,
						AnchorPoint = Vector2.new(0.5, 0.5),
						Position = UDim2.new(0.5, 0, 0.5, 0),
						Size = UDim2.fromOffset(12, 12),
						Image = Assets.ArrowsSpriteSheet,
						ImageRectSize = Vector2.new(16, 16),
						ImageRectOffset = Vector2.new(16, 0),
						ImageColor3 = theme:GetColor(Enum.StudioStyleGuideColor.ButtonText),
					}),
				}),
			}),

			StrokeFrame = highlightEnabled and React.createElement("Frame", {
				Active = false,
				BackgroundTransparency = 1,
				Size = UDim2.fromScale(1, 1),
				ZIndex = 2,
			}, {
				UIStroke = React.createElement("UIStroke", {
					Thickness = 1,
					Transparency = 0,
					ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
					BorderStrokePosition = Enum.BorderStrokePosition.Inner,
					LineJoinMode = Enum.LineJoinMode.Miter,
					Color = theme:GetColor(
						Enum.StudioStyleGuideColor.InputFieldBorder,
						Enum.StudioStyleGuideModifier.Selected
					),
				}),
			}),
		}),

		DisplayLabel = React.createElement("TextLabel", {
			Visible = not isEditing,
			ClipsDescendants = true,
			BackgroundTransparency = 1,
			Size = UDim2.fromScale(1, 1),
			FontFace = Font.fromName("SourceSansPro"),
			TextYAlignment = Enum.TextYAlignment.Center,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextTruncate = Enum.TextTruncate.AtEnd,
			TextColor3 = theme:GetColor(
				Enum.StudioStyleGuideColor.MainText,
				if props.Disabled then Enum.StudioStyleGuideModifier.Disabled else nil
			),
			Text = props.Text,
			TextSize = 14,
		}, {
			UIPadding = React.createElement("UIPadding", {
				PaddingLeft = UDim.new(0, 4),
				PaddingRight = UDim.new(0, 4),
			}),
		}),
	})
end

return React.forwardRef(InputBox)
