local uiRoot = script:FindFirstAncestor("UserInterface")
local Constants = require(uiRoot.Components.Properties.Foundational.Constants)
local NumberBox = require(uiRoot.Components.Properties.Foundational.NumberBox)

local pkgs = uiRoot.Parent.Parent
local StudioComponents = require(pkgs.StudioComponents)
local React = require(pkgs.React)

export type Props = {
	AnchorPoint: Vector2?,
	Position: UDim2?,
	Size: UDim2?,

	FieldName: string,
	HighlightOnFocus: boolean?,

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
	local textBoxRef = React.useRef(nil :: TextBox?)

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
			Input = React.createElement(NumberBox, {
				Size = UDim2.fromScale(1, 1),

				Value = props.Value,
				OnValueSubmitted = props.OnValueSubmitted,

				Min = props.Min,
				Max = props.Max,
				Step = props.Step,

				HighlightMode = "TextboxFocused",
				HighlightOnFocus = props.HighlightOnFocus,
				Disabled = props.Disabled,

				ref = textBoxRef,
			}),
		}),
	})
end

return NumberInput
