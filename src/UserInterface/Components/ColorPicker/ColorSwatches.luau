local pkgs = script:FindFirstAncestor("UserInterface").Parent.Parent
local StudioComponents = require(pkgs.StudioComponents)
local React = require(pkgs.React)

export type Props = {
	AnchorPoint: Vector2?,
	Position: UDim2?,
	Size: UDim2?,

	Colors: { Color3 },
	OnActivated: (Color3) -> ()?,

	Disabled: boolean?,
}

local function ColorSwatches(props: Props)
	local theme = StudioComponents.useTheme()

	local swatchCells: { [string]: React.ReactNode } = {}
	for i, color in props.Colors do
		swatchCells[tostring(i)] = React.createElement("Frame", {
			BackgroundTransparency = 1,
			Size = UDim2.fromOffset(22, 18),
			LayoutOrder = i,
		}, {
			Button = React.createElement("ImageButton", {
				BackgroundColor3 = color,
				BorderSizePixel = 0,
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.fromScale(0.5, 0.5),
				Size = UDim2.new(1, -4, 1, -4),
				Image = "",

				AutoButtonColor = not props.Disabled,

				[React.Event.Activated] = function()
					if not props.Disabled and props.OnActivated then
						props.OnActivated(color)
					end
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

			UIStroke = React.createElement("UIStroke", {
				Thickness = 1,
				Transparency = 0,
				ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
				BorderStrokePosition = Enum.BorderStrokePosition.Inner,
				LineJoinMode = Enum.LineJoinMode.Miter,
				Color = theme:GetColor(Enum.StudioStyleGuideColor.Border),
			}),
		})
	end

	return React.createElement("Frame", {
		BackgroundTransparency = 1,
		AnchorPoint = props.AnchorPoint,
		Position = props.Position,
		Size = props.Size,
	}, {
		UIGridLayout = React.createElement("UIGridLayout", {
			FillDirection = Enum.FillDirection.Horizontal,
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
			VerticalAlignment = Enum.VerticalAlignment.Top,
			SortOrder = Enum.SortOrder.LayoutOrder,
			CellPadding = UDim2.fromOffset(6, 6),
			CellSize = UDim2.fromOffset(22, 18),
		}),
	}, swatchCells)
end

return ColorSwatches
