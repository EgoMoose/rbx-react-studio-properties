local uiRoot = script:FindFirstAncestor("UserInterface")
local useRefProperty = require(uiRoot.Hooks.useRefProperty)
local Assets = require(uiRoot.Assets)

local pkgs = uiRoot.Parent.Parent
local StudioComponents = require(pkgs.StudioComponents)
local ReactRipple = require(pkgs.ReactRipple)
local React = require(pkgs.React)

export type Props = {
	AnchorPoint: Vector2?,
	Position: UDim2?,
	Size: UDim2?,

	ScrollInset: UDim?,
	ScrollBarThickness: number?,
	ScrollBarTransparency: number?,
	ScrollBarFades: boolean?,

	GradientHeight: number?,
	GradientColor: Color3?,

	Disabled: boolean?,

	children: React.ReactNode?,
}

local function useScrollTransparency(initial: number)
	local transparency, control = ReactRipple.useSpring(initial)
	return transparency, React.useCallback(function(value: number)
		control:setGoal(value)
	end, {})
end

local function VerticalScroll(props: Props)
	local theme = StudioComponents.useTheme()
	local scrollTransparency, setScrollTransparency = useScrollTransparency(1)

	local contentRef = React.useRef(nil :: Frame?)
	local scrollRef = React.useRef(nil :: ScrollingFrame?)

	local contentSize = useRefProperty(contentRef, "AbsoluteSize", Vector2.zero)
	local canvasPosition = useRefProperty(scrollRef, "CanvasPosition", Vector2.zero)

	local scrollInset = props.ScrollInset or UDim.new(0, 0)
	local scrollVisibleTransparency = props.ScrollBarTransparency or 0

	return React.createElement("Frame", {
		BackgroundTransparency = 1,
		AnchorPoint = props.AnchorPoint,
		Position = props.Position,
		Size = props.Size,

		[React.Event.MouseEnter] = function()
			setScrollTransparency(0)
		end,
		[React.Event.MouseLeave] = function()
			setScrollTransparency(1)
		end,
	}, {
		Clipped = React.createElement("Frame", {
			BackgroundTransparency = 1,
			Size = UDim2.fromScale(1, 1),
			ClipsDescendants = true,
			ZIndex = -2,
		}, {
			Content = React.createElement("Frame", {
				Position = UDim2.fromOffset(0, -canvasPosition.Y),
				AutomaticSize = Enum.AutomaticSize.Y,
				Size = UDim2.fromScale(1, 0),
				BackgroundTransparency = 1,
				ref = contentRef,
			}, props.children),
		}),

		Gradient = React.createElement("Frame", {
			BorderSizePixel = 0,
			BackgroundColor3 = props.GradientColor or theme:GetColor(Enum.StudioStyleGuideColor.MainBackground),
			AnchorPoint = Vector2.new(0, 1),
			Position = UDim2.fromScale(0, 1),
			Size = UDim2.new(1, 0, 0, props.GradientHeight or 0),
			ZIndex = -1,
		}, {
			Gradient = React.createElement("UIGradient", {
				Transparency = NumberSequence.new(0, 1),
				Rotation = -90,
			}),
		}),

		ScrollingFrame = React.createElement("ScrollingFrame", {
			BorderSizePixel = 0,
			BackgroundTransparency = 1,
			Size = UDim2.new(1 + scrollInset.Scale, scrollInset.Offset, 1, 0),
			CanvasSize = UDim2.fromOffset(0, contentSize.Y),

			ScrollingEnabled = not props.Disabled,
			ScrollBarThickness = props.ScrollBarThickness or 4,
			ScrollingDirection = Enum.ScrollingDirection.Y,
			ScrollBarImageColor3 = theme:GetColor(Enum.StudioStyleGuideColor.DimmedText),
			ScrollBarImageTransparency = scrollTransparency:map(function(value: number)
				if props.ScrollBarFades then
					return math.lerp(scrollVisibleTransparency, 1, value)
				end
				return scrollVisibleTransparency
			end),

			TopImage = Assets.scroll["scroll-top"],
			MidImage = Assets.scroll["scroll-middle"],
			BottomImage = Assets.scroll["scroll-bottom"],

			ref = scrollRef,
		}),
	})
end

return VerticalScroll
