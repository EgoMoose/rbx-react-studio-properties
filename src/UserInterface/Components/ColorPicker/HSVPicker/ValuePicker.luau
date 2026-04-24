local uiRoot = script:FindFirstAncestor("UserInterface")
local useMouseDrag = require(uiRoot.Hooks.useMouseDrag)
local Assets = require(uiRoot.Assets)

local pkgs = uiRoot.Parent.Parent
local StudioComponents = require(pkgs.StudioComponents)
local React = require(pkgs.React)

export type Props = {
	AnchorPoint: Vector2?,
	Position: UDim2?,
	Size: UDim2?,

	HSV: { number },
	OnChanged: (number) -> ()?,

	Disabled: boolean?,
}

local function ValuePicker(props: Props)
	local theme = StudioComponents.useTheme()

	local hue, saturation, value = props.HSV[1], props.HSV[2], props.HSV[3]
	local drag = useMouseDrag(function(rbx: GuiObject, input: InputObject)
		local mousePos = input.Position.Y
		local alpha = math.clamp((mousePos - rbx.AbsolutePosition.Y) / rbx.AbsoluteSize.Y, 0, 1)

		if props.OnChanged then
			props.OnChanged(1 - alpha)
		end
	end, { value, props.OnChanged } :: { any })

	React.useEffect(function()
		if props.Disabled and drag.isActive() then
			drag.cancel()
		end
	end, { props.Disabled, drag.isActive() })

	return React.createElement("Frame", {
		BorderColor3 = theme:GetColor(Enum.StudioStyleGuideColor.Border),
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		BackgroundTransparency = if props.Disabled then 0.75 else 0,

		AnchorPoint = props.AnchorPoint,
		Position = props.Position,
		Size = props.Size,

		[React.Event.InputBegan] = if not props.Disabled then drag.onInputBegan else nil,
		[React.Event.InputChanged] = if not props.Disabled then drag.onInputChanged else nil,
		[React.Event.InputEnded] = if not props.Disabled then drag.onInputEnded else nil,
	}, {
		Gradient = React.createElement("UIGradient", {
			Color = ColorSequence.new(Color3.fromRGB(0, 0, 0), Color3.fromHSV(hue, saturation, 1)),
			Rotation = 270,
		}),
		Arrow = React.createElement("ImageLabel", {
			BackgroundTransparency = 1,
			AnchorPoint = Vector2.new(0, 0.5),
			Position = UDim2.new(1, 1, 1 - value, 0),
			Size = UDim2.fromOffset(5, 9),

			Image = Assets.SliderArrow,
			ImageColor3 = theme:GetColor(Enum.StudioStyleGuideColor.TitlebarText),

			Visible = not props.Disabled,
		}),
		Overlay = React.createElement("Frame", {
			Size = UDim2.fromScale(1, 1),
			BorderSizePixel = 0,
			BackgroundColor3 = theme:GetColor(Enum.StudioStyleGuideColor.MainBackground),
			BackgroundTransparency = 0.5,
			Visible = not not props.Disabled,
			ZIndex = 2,
		}),
	})
end

return ValuePicker
