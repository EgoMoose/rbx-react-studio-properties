local uiRoot = script:FindFirstAncestor("UserInterface")
local Observables = require(uiRoot.Observables)
local Assets = require(uiRoot.Assets)

local pkgs = uiRoot.Parent.Parent
local StudioComponents = require(pkgs.StudioComponents)
local React = require(pkgs.React)

export type Props = {
	AnchorPoint: Vector2?,
	Position: UDim2?,

	GroupName: string,
	ForceExpanded: boolean?,

	LayoutOrder: number?,
	ZIndex: number?,
	Disabled: boolean?,

	children: React.ReactNode?,
}

local function PropertyGroup(props: Props)
	local theme = StudioComponents.useTheme()
	local isHovered, setIsHovered = React.useState(false)
	local isExpandedRaw, setIsExpandedRaw = React.useState(true)
	local isExpanded = props.ForceExpanded or isExpandedRaw

	local isHoveringDisabled = Observables.hoveringDisabled:use()
	if isHoveringDisabled then
		isHovered = false
	end

	React.useEffect(function()
		if props.ForceExpanded then
			setIsExpandedRaw(true)
		end
	end, { props.ForceExpanded })

	return React.createElement("Frame", {
		BackgroundTransparency = 1,
		AnchorPoint = props.AnchorPoint,
		Position = props.Position,
		Size = UDim2.fromScale(1, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		LayoutOrder = props.LayoutOrder,
		ZIndex = props.ZIndex,
	}, {
		UIListLayout = React.createElement("UIListLayout", {
			FillDirection = Enum.FillDirection.Vertical,
			SortOrder = Enum.SortOrder.LayoutOrder,
			Padding = UDim.new(0, 0),
		}),

		Header = React.createElement("Frame", {
			BackgroundColor3 = if isHovered
				then theme:GetColor(Enum.StudioStyleGuideColor.InputFieldBackground)
				else theme:GetColor(Enum.StudioStyleGuideColor.Titlebar),
			BorderColor3 = theme:GetColor(Enum.StudioStyleGuideColor.Border),

			Size = UDim2.new(1, 0, 0, 24),
			LayoutOrder = 1,

			[React.Event.MouseEnter] = function()
				setIsHovered(true)
			end,
			[React.Event.MouseLeave] = function()
				setIsHovered(false)
			end,
		}, {
			Button = props.children and React.createElement("Frame", {
				Active = false,
				BackgroundTransparency = 1,
				Size = UDim2.new(0, 22, 1, 0),

				[React.Event.InputBegan] = function(_, input: InputObject)
					if input.UserInputType == Enum.UserInputType.MouseButton1 then
						setIsExpandedRaw(not isExpandedRaw)
					end
				end,
			}, {
				Icon = React.createElement("ImageLabel", {
					BackgroundTransparency = 1,
					AnchorPoint = Vector2.new(0.5, 0.5),
					Position = UDim2.fromScale(0.5, 0.5),
					Size = UDim2.fromOffset(16, 16),
					Image = Assets.ArrowsSpriteSheet,
					ImageRectSize = Vector2.new(16, 16),
					ImageRectOffset = if isExpanded then Vector2.new(16, 0) else Vector2.new(16, 16),
					ImageColor3 = theme:GetColor(
						Enum.StudioStyleGuideColor.ButtonText,
						if props.Disabled
							then Enum.StudioStyleGuideModifier.Disabled
							else Enum.StudioStyleGuideModifier.Default
					),
				}),
			}),
			Label = React.createElement("TextLabel", {
				BackgroundTransparency = 1,
				Position = UDim2.fromOffset(22, 0),
				Size = UDim2.new(1, -22, 1, 0),
				FontFace = Font.fromName("SourceSansPro", Enum.FontWeight.Bold),
				TextYAlignment = Enum.TextYAlignment.Center,
				TextXAlignment = Enum.TextXAlignment.Left,
				TextTruncate = Enum.TextTruncate.AtEnd,
				TextColor3 = theme:GetColor(
					Enum.StudioStyleGuideColor.MainText,
					if props.Disabled
						then Enum.StudioStyleGuideModifier.Disabled
						else Enum.StudioStyleGuideModifier.Default
				),
				Text = props.GroupName,
				TextSize = 14,
			}, {
				UIPadding = React.createElement("UIPadding", {
					PaddingLeft = UDim.new(0, 4),
					PaddingRight = UDim.new(0, 4),
				}),
			}),
		}),
		Content = React.createElement("Frame", {
			BackgroundTransparency = 1,
			Size = UDim2.fromScale(1, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			Visible = isExpanded,
			LayoutOrder = 2,
		}, props.children),
	})
end

return PropertyGroup
