local pkgs = script:FindFirstAncestor("UserInterface").Parent.Parent
local StudioComponents = require(pkgs.StudioComponents)
local React = require(pkgs.React)

local foundationalRoot = script.Parent.Parent.Foundational
local PropertyLine = require(foundationalRoot.PropertyLine)

export type Props = {
	AnchorPoint: Vector2?,
	Position: UDim2?,

	FieldName: string,

	Value: boolean,
	OnValueSubmitted: (boolean) -> ()?,

	Indent: number?,
	LayoutOrder: number?,
	ZIndex: number?,
	Disabled: boolean?,

	children: React.ReactNode?,
}

local function StringProperty(props: Props)
	return React.createElement(PropertyLine, {
		AnchorPoint = props.AnchorPoint,
		Position = props.Position,

		FieldName = props.FieldName,

		OnActivated = function()
			if props.OnValueSubmitted then
				props.OnValueSubmitted(not props.Value)
			end
		end,

		Indent = props.Indent,
		LayoutOrder = props.LayoutOrder,
		ZIndex = props.ZIndex,
		Disabled = props.Disabled,

		Interface = React.createElement(React.Fragment, nil, {
			Checkbox = React.createElement(StudioComponents.Checkbox, {
				AnchorPoint = Vector2.new(0, 0.5),
				Position = UDim2.fromScale(0, 0.5),
				Value = props.Value,
				Disabled = props.Disabled,
			}),

			UIPadding = React.createElement("UIPadding", {
				PaddingLeft = UDim.new(0, 4),
				PaddingRight = UDim.new(0, 4),
			}),
		}) :: React.ReactNode,
	}, props.children)
end

return StringProperty
