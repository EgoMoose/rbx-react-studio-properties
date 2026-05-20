local uiRoot = script:FindFirstAncestor("UserInterface")
local TextSanitizers = require(uiRoot.Helpers.TextSanitizers)

local pkgs = uiRoot.Parent.Parent
local StudioComponents = require(pkgs.StudioComponents)
local React = require(pkgs.React)

local foundationalRoot = script.Parent.Parent.Foundational
local PropertyLine = require(foundationalRoot.PropertyLine)
local NumberBox = require(foundationalRoot.NumberBox)

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

	local editingEnabled, setEditingEnabled = React.useState(false)
	local textBoxRef = React.useRef(nil :: TextBox?)

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
			Input = React.createElement(NumberBox, {
				Size = if isSliderEnabled then UDim2.fromScale(1 / 3, 1) else UDim2.fromScale(1, 1),

				Min = minValue,
				Max = maxValue,
				Step = props.Step,

				OnFocusLost = function()
					setEditingEnabled(false)
				end,

				Value = props.Value,
				OnValueSubmitted = props.OnValueSubmitted,

				EditingDisabled = not editingEnabled,
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
				Value = props.Value,
				OnChanged = props.OnValueSubmitted,
				Disabled = props.Disabled,
			}),
		}) :: React.ReactNode,
	}, props.children)
end

return NumberProperty
