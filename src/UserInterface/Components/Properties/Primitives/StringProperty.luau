local pkgs = script:FindFirstAncestor("UserInterface").Parent.Parent
local React = require(pkgs.React)

local foundationalRoot = script.Parent.Parent.Foundational
local PropertyLine = require(foundationalRoot.PropertyLine)
local InputBox = require(foundationalRoot.InputBox)

export type Props = {
	AnchorPoint: Vector2?,
	Position: UDim2?,

	FieldName: string,
	ForceExpanded: boolean?,

	Value: string,
	OnValueSubmitted: (string) -> ()?,

	Indent: number?,
	LayoutOrder: number?,
	ZIndex: number?,
	Disabled: boolean?,

	children: React.ReactNode?,
}

local function StringProperty(props: Props)
	local text, setText = React.useState(props.Value)
	local editingEnabled, setEditingEnabled = React.useState(false)
	local textBoxRef = React.useRef(nil :: TextBox?)

	React.useEffect(function()
		setText(props.Value)
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
			if textBox and not textBox:IsFocused() then
				textBox:CaptureFocus()
				if not editingEnabled then
					textBox.SelectionStart = 1
					textBox.CursorPosition = #textBox.Text + 1
				end
			end

			setEditingEnabled(true)
		end,

		Indent = props.Indent,
		LayoutOrder = props.LayoutOrder,
		ZIndex = props.ZIndex,
		Disabled = props.Disabled,

		Interface = React.createElement(React.Fragment, nil, {
			Input = React.createElement(InputBox, {
				Size = UDim2.fromScale(1, 1),

				Text = text,
				OnTextChanged = setText,
				OnTextSubmitted = function(value)
					setText(props.Value)
					setEditingEnabled(false)
					if props.OnValueSubmitted then
						props.OnValueSubmitted(value)
					end
				end,

				EditingEnabled = editingEnabled,
				HighlightMode = "TextboxFocused",

				Disabled = props.Disabled,
				ref = textBoxRef,
			}),
		}) :: React.ReactNode,
	}, props.children)
end

return StringProperty
