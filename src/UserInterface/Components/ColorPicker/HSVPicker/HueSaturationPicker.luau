local uiRoot = script:FindFirstAncestor("UserInterface")
local useMouseDrag = require(uiRoot.Hooks.useMouseDrag)

local pkgs = uiRoot.Parent.Parent
local StudioComponents = require(pkgs.StudioComponents)
local React = require(pkgs.React)

export type Props = {
	AnchorPoint: Vector2?,
	Position: UDim2?,
	Size: UDim2?,

	HSV: { number },
	OnChanged: (number, number) -> ()?,

	Disabled: boolean?,
}

local function generateHueKeypoints(value: number)
	local keypoints = {}
	local regions = 6
	for hue = 0, regions do
		local offset = hue / regions
		local color = Color3.fromHSV((regions - hue) / regions, 1, value)
		table.insert(keypoints, ColorSequenceKeypoint.new(offset, color))
	end
	return ColorSequence.new(keypoints)
end

local HUE_SEQUENCE = generateHueKeypoints(1)

local function HueSaturationPicker(props: Props)
	local theme = StudioComponents.useTheme()

	local hue, saturation = props.HSV[1], props.HSV[2]
	local dragger = useMouseDrag(function(rbx: GuiObject, input: InputObject)
		local mousePos = Vector2.new(input.Position.X, input.Position.Y)
		local uvCoords = (mousePos - rbx.AbsolutePosition) / rbx.AbsoluteSize
		uvCoords = uvCoords:Max(Vector2.zero):Min(Vector2.one)

		if props.OnChanged then
			props.OnChanged(1 - uvCoords.X, 1 - uvCoords.Y)
		end
	end, { hue, saturation, props.OnChanged } :: { any })

	React.useEffect(function()
		if props.Disabled and dragger.isActive() then
			dragger.cancel()
		end
	end, { props.Disabled, dragger.isActive() })

	return React.createElement("Frame", {
		BackgroundColor3 = theme:GetColor(Enum.StudioStyleGuideColor.MainBackground),
		BorderColor3 = theme:GetColor(Enum.StudioStyleGuideColor.Border),
		AnchorPoint = props.AnchorPoint,
		Position = props.Position,
		Size = props.Size,
	}, {
		Gradients = React.createElement("Frame", {
			BackgroundTransparency = 1,
			Size = UDim2.fromScale(1, 1),
			ZIndex = 1,
		}, {
			Hue = React.createElement("Frame", {
				BorderSizePixel = 0,
				BackgroundColor3 = Color3.fromRGB(255, 255, 255),
				Size = UDim2.fromScale(1, 1),
				ZIndex = 1,
			}, {
				UIGradient = React.createElement("UIGradient", {
					Color = HUE_SEQUENCE,
				}),
			}),
			Sat = React.createElement("Frame", {
				BorderSizePixel = 0,
				BackgroundColor3 = Color3.fromRGB(255, 255, 255),
				Size = UDim2.fromScale(1, 1),
				ZIndex = 2,
			}, {
				UIGradient = React.createElement("UIGradient", {
					Color = ColorSequence.new(Color3.fromHSV(1, 0, 1)),
					Transparency = NumberSequence.new(1, 0),
					Rotation = 90,
				}),
			}),
		}),

		Clipping = React.createElement("Frame", {
			BackgroundTransparency = 1,
			Size = UDim2.fromScale(1, 1),
			ClipsDescendants = true,
			ZIndex = 2,

			[React.Event.InputBegan] = if not props.Disabled then dragger.onInputBegan else nil,
			[React.Event.InputChanged] = if not props.Disabled then dragger.onInputChanged else nil,
			[React.Event.InputEnded] = if not props.Disabled then dragger.onInputEnded else nil,
		}, {
			Cursor = React.createElement("Frame", {
				BackgroundTransparency = 1,
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.fromScale(1 - hue, 1 - saturation),
				Size = UDim2.fromOffset(20, 20),
				Visible = not props.Disabled,
			}, {
				Vertical = React.createElement("Frame", {
					BorderSizePixel = 0,
					BackgroundColor3 = Color3.new(0, 0, 0),
					AnchorPoint = Vector2.new(0.5, 0.5),
					Position = UDim2.fromScale(0.5, 0.5),
					Size = UDim2.new(0, 2, 1, 0),
				}),
				Horizontal = React.createElement("Frame", {
					BorderSizePixel = 0,
					BackgroundColor3 = Color3.new(0, 0, 0),
					AnchorPoint = Vector2.new(0.5, 0.5),
					Position = UDim2.fromScale(0.5, 0.5),
					Size = UDim2.new(1, 0, 0, 2),
				}),
			}),
		}),

		Overlay = React.createElement("Frame", {
			Size = UDim2.fromScale(1, 1),
			BorderSizePixel = 0,
			BackgroundColor3 = theme:GetColor(Enum.StudioStyleGuideColor.MainBackground),
			BackgroundTransparency = 0.5,
			Visible = not not props.Disabled,
			ZIndex = 3,
		}),
	})
end

return HueSaturationPicker
