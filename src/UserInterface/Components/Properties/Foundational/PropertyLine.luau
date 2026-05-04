local uiRoot = script:FindFirstAncestor("UserInterface")
local Constants = require(script.Parent.Constants)
local Observables = require(uiRoot.Observables)
local Assets = require(uiRoot.Assets)

local pkgs = uiRoot.Parent.Parent
local StudioComponents = require(pkgs.StudioComponents)
local React = require(pkgs.React)

export type Props = {
	AnchorPoint: Vector2?,
	Position: UDim2?,

	FieldName: string,
	ForceExpanded: boolean?,

	OnFocus: () -> ()?,
	OnFocusLost: () -> ()?,
	OnActivated: (InputObject) -> ()?,

	Indent: number?,
	LayoutOrder: number?,
	ZIndex: number?,
	Disabled: boolean?,

	Interface: React.ReactNode?,

	children: React.ReactNode?,
}

local function getBackgroundColor(theme: StudioTheme, isHovered: boolean, isFocused: boolean)
	if isFocused then
		return theme:GetColor(Enum.StudioStyleGuideColor.ScriptSelectionBackground)
	elseif isHovered then
		return theme:GetColor(Enum.StudioStyleGuideColor.InputFieldBackground)
	else
		return theme:GetColor(Enum.StudioStyleGuideColor.MainBackground)
	end
end

local function PropertyLine(props: Props)
	local indent = math.floor(math.max(props.Indent or 0, 1))

	local theme = StudioComponents.useTheme()
	local isHovered, setIsHovered = React.useState(false)
	local isFocused, setIsFocused = React.useState(false)

	local isHoveringDisabled = Observables.hoveringDisabled:use()
	if isHoveringDisabled then
		isHovered = false
	end

	local isExpanded, setIsExpanded = React.useState(false)
	local expandArrowHoverRef = React.useRef(false)
	if props.ForceExpanded ~= nil then
		isExpanded = props.ForceExpanded
	end

	local inputObjectRef = React.useRef(nil :: InputObject?)

	React.useEffect(function()
		local connection
		if inputObjectRef.current and isFocused then
			connection = inputObjectRef.current:GetPropertyChangedSignal("UserInputState"):Connect(function()
				if inputObjectRef.current.UserInputState == Enum.UserInputState.Begin and not isHovered then
					setIsFocused(false)
				end
			end)
		end

		return function()
			if connection then
				connection:Disconnect()
			end
		end
	end, { isFocused, isHovered })

	React.useEffect(function()
		if props.Disabled then
			setIsFocused(false)
		end
	end, { props.Disabled })

	React.useEffect(function()
		if isFocused and props.OnFocus then
			props.OnFocus()
		elseif not isFocused and props.OnFocusLost then
			props.OnFocusLost()
		end
	end, { isFocused })

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

		Body = React.createElement("Frame", {
			BackgroundColor3 = getBackgroundColor(theme, isHovered, isFocused and not props.Disabled),
			BorderColor3 = theme:GetColor(Enum.StudioStyleGuideColor.Border),
			BorderSizePixel = 0,
			Size = UDim2.new(1, 0, 0, Constants.LineHeight),

			[React.Event.MouseEnter] = function()
				setIsHovered(true)
			end,
			[React.Event.MouseLeave] = function()
				setIsHovered(false)
			end,

			LayoutOrder = 1,
		}, {
			Click = React.createElement("Frame", {
				Active = false,
				BackgroundTransparency = 1,
				Size = UDim2.fromScale(1, 1),
				ZIndex = 2,

				[React.Event.InputBegan] = function(_, input: InputObject)
					if not props.Disabled and input.UserInputType == Enum.UserInputType.MouseButton1 then
						inputObjectRef.current = input

						setIsFocused(true)
						if props.OnActivated and not expandArrowHoverRef.current then
							props.OnActivated(input)
						end
					end
				end,
			}),

			Content = React.createElement("Frame", {
				BackgroundTransparency = 1,
				Size = UDim2.fromScale(1, 1),
			}, {
				Indent = React.createElement("Frame", {
					BackgroundTransparency = 1,
					Size = UDim2.new(0, Constants.LineHeight * indent, 1, 0),
				}, {
					Button = props.children and props.ForceExpanded ~= false and React.createElement("Frame", {
						Active = false,
						BackgroundTransparency = 1,
						AnchorPoint = Vector2.new(1, 0),
						Position = UDim2.fromScale(1, 0),
						Size = UDim2.fromScale(1, 1),
						SizeConstraint = Enum.SizeConstraint.RelativeYY,

						[React.Event.InputBegan] = function(_, input: InputObject)
							if
								props.ForceExpanded == nil
								and input.UserInputType == Enum.UserInputType.MouseButton1
							then
								setIsExpanded(not isExpanded)
							end
						end,

						[React.Event.MouseEnter] = function()
							expandArrowHoverRef.current = true
						end,

						[React.Event.MouseLeave] = function()
							expandArrowHoverRef.current = false
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
				}),

				Left = React.createElement("Frame", {
					BorderSizePixel = 0,
					BackgroundColor3 = getBackgroundColor(
						theme,
						isHovered and not props.Disabled,
						isFocused and not props.Disabled
					),
					Size = UDim2.new(0.5, -Constants.LineHeight * indent, 1, 0),
					Position = UDim2.fromOffset(Constants.LineHeight * indent, 0),
					ZIndex = -1,
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
						TextXAlignment = Enum.TextXAlignment.Left,
						TextTruncate = Enum.TextTruncate.AtEnd,
						TextColor3 = theme:GetColor(
							Enum.StudioStyleGuideColor.MainText,
							if props.Disabled then Enum.StudioStyleGuideModifier.Disabled else nil
						),
						Text = props.FieldName,
						TextSize = 14,
					}),
				}),
				BorderLine = React.createElement("Frame", {
					BackgroundColor3 = theme:GetColor(Enum.StudioStyleGuideColor.Border),
					BorderSizePixel = 0,
					Size = UDim2.new(0, 1, 1, 0),
					Position = UDim2.new(0.5, -1, 0, 0),
				}),
				Right = React.createElement("Frame", {
					BackgroundColor3 = getBackgroundColor(
						theme,
						isHovered and not props.Disabled,
						isFocused and not props.Disabled
					),
					BorderColor3 = theme:GetColor(Enum.StudioStyleGuideColor.Border),
					BorderSizePixel = 0,
					Position = UDim2.fromScale(0.5, 0),
					Size = UDim2.fromScale(0.5, 1),
				}, props.Interface),
			}),
		}),

		BorderLine = React.createElement("Frame", {
			BackgroundColor3 = theme:GetColor(Enum.StudioStyleGuideColor.Border),
			BorderSizePixel = 0,
			Size = UDim2.new(1, 0, 0, 1),
			LayoutOrder = 2,
		}),

		Expansion = React.createElement("Frame", {
			BackgroundTransparency = 1,
			Size = UDim2.fromScale(1, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			Visible = isExpanded,
			LayoutOrder = 3,
		}, props.children),
	})
end

return PropertyLine
