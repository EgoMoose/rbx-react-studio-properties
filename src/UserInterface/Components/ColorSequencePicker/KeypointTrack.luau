local uiRoot = script:FindFirstAncestor("UserInterface")
local useMouseDrag = require(uiRoot.Hooks.useMouseDrag)
local Assets = require(uiRoot.Assets)

local pkgs = uiRoot.Parent.Parent
local StudioComponents = require(pkgs.StudioComponents)
local React = require(pkgs.React)

local Keypoints = require(script.Parent.Keypoints)

local MARKER_HEIGHT = 10
local GRAB_DISTANCE = 6
local SELECTED_COLOR = Color3.fromRGB(240, 226, 76)
local HOVER_LINE_COLOR = Color3.fromRGB(0, 0, 0)

export type Props = {
	AnchorPoint: Vector2?,
	Position: UDim2?,
	Size: UDim2?,

	Keypoints: { Keypoints.Keypoint },
	SelectedId: number?,

	OnSelect: (id: number) -> (),
	OnAdd: (time: number) -> number?,
	OnMove: (id: number, time: number) -> (),

	Disabled: boolean?,
}

type DragInfo = {
	Id: number,
	Offset: number,
	Movable: boolean,
}

local function getAlpha(rbx: GuiObject, input: InputObject)
	local width = math.max(rbx.AbsoluteSize.X, 1)
	return math.clamp((input.Position.X - rbx.AbsolutePosition.X) / width, 0, 1)
end

local function KeypointTrack(props: Props)
	local theme = StudioComponents.useTheme()
	local dragRef = React.useRef(nil :: DragInfo?)

	local drag = useMouseDrag(
		function(rbx: GuiObject, input: InputObject)
			local info = dragRef.current
			if info and info.Movable then
				props.OnMove(info.Id, math.clamp(getAlpha(rbx, input) + info.Offset, 0, 1))
			end
		end,
		nil,
		function(rbx: GuiObject, input: InputObject)
			local width = math.max(rbx.AbsoluteSize.X, 1)
			local alpha = getAlpha(rbx, input)

			local nearest, nearestDistance = nil, math.huge
			for _, keypoint in props.Keypoints do
				local distance = math.abs(keypoint.Time - alpha) * width
				if keypoint.Id == props.SelectedId then
					distance = distance - 0.5
				end
				if distance <= GRAB_DISTANCE and distance < nearestDistance then
					nearest, nearestDistance = keypoint, distance
				end
			end

			if nearest then
				dragRef.current = {
					Id = nearest.Id,
					Offset = nearest.Time - alpha,
					Movable = nearest.Edge == nil,
				}
				props.OnSelect(nearest.Id)
			else
				local id = props.OnAdd(alpha)
				dragRef.current = if id then { Id = id, Offset = 0, Movable = true } else nil
			end
		end,
		function()
			dragRef.current = nil
		end
	)

	React.useEffect(function()
		if props.Disabled and drag.isActive() then
			drag.cancel()
		end
	end, { props.Disabled, drag.isActive() })

	local hoverX, setHoverX = React.useBinding(nil :: number?)
	local gradientHeight, setGradientHeight = React.useState(0)
	local gradientRef = React.useRef(nil :: Frame?)

	React.useEffect(function()
		if gradientRef.current then
			setGradientHeight(gradientRef.current.AbsoluteSize.Y)
		end
	end, {})

	local function updateHover(rbx: GuiObject, input: InputObject)
		local size = rbx.AbsoluteSize
		local relativeY = input.Position.Y - rbx.AbsolutePosition.Y

		if relativeY >= size.Y - MARKER_HEIGHT then
			setHoverX(nil)
			return
		end

		local x = math.floor(input.Position.X - rbx.AbsolutePosition.X)
		setHoverX(math.clamp(x, 0, math.max(size.X - 1, 0)))
	end

	React.useEffect(function()
		if props.Disabled then
			setHoverX(nil)
		end
	end, { props.Disabled })

	local dots: { [string]: React.ReactNode } = {
		UIListLayout = React.createElement("UIListLayout", {
			FillDirection = Enum.FillDirection.Vertical,
			SortOrder = Enum.SortOrder.LayoutOrder,
			Padding = UDim.new(0, 1),
		}),
	}
	for i = 1, math.ceil(gradientHeight / 2) do
		dots[`Dot{i}`] = React.createElement("Frame", {
			BorderSizePixel = 0,
			BackgroundColor3 = HOVER_LINE_COLOR,
			Size = UDim2.fromOffset(1, 1),
			LayoutOrder = i,
		})
	end

	local markers: { [string]: React.ReactNode } = {}
	for _, keypoint in props.Keypoints do
		local isSelected = keypoint.Id == props.SelectedId
		markers[`Marker{keypoint.Id}`] = React.createElement("ImageLabel", {
			BackgroundTransparency = 1,
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.new(keypoint.Time, 0, 1, -MARKER_HEIGHT + 5),
			Size = UDim2.fromOffset(10, 9),
			Rotation = 90,

			Image = Assets.SliderArrow,
			ImageColor3 = if isSelected
				then SELECTED_COLOR
				else theme:GetColor(Enum.StudioStyleGuideColor.TitlebarText),
			ImageTransparency = if props.Disabled then 0.5 else 0,

			ZIndex = if isSelected then 2 else 1,
		})
	end

	return React.createElement("Frame", {
		BackgroundTransparency = 1,
		AnchorPoint = props.AnchorPoint,
		Position = props.Position,
		Size = props.Size,

		[React.Event.InputBegan] = if not props.Disabled then drag.onInputBegan else nil,
		[React.Event.InputChanged] = if not props.Disabled
			then function(rbx: GuiObject, input: InputObject)
				drag.onInputChanged(rbx, input)
				if input.UserInputType == Enum.UserInputType.MouseMovement then
					updateHover(rbx, input)
				end
			end
			else nil,
		[React.Event.InputEnded] = if not props.Disabled then drag.onInputEnded else nil,
		[React.Event.MouseLeave] = function()
			setHoverX(nil)
		end,
	}, {
		HoverLine = React.createElement("Frame", {
			BackgroundTransparency = 1,
			ClipsDescendants = true,
			Position = hoverX:map(function(x: number?)
				return UDim2.fromOffset(x or 0, 0)
			end),
			Size = UDim2.new(0, 1, 1, -MARKER_HEIGHT),
			Visible = hoverX:map(function(x: number?)
				return x ~= nil
			end),
			ZIndex = 2,
		}, dots),

		Gradient = React.createElement("Frame", {
			BorderColor3 = theme:GetColor(Enum.StudioStyleGuideColor.Border),
			BackgroundColor3 = Color3.new(1, 1, 1),
			Size = UDim2.new(1, 0, 1, -MARKER_HEIGHT),

			[React.Change.AbsoluteSize] = function(rbx: Frame)
				setGradientHeight(rbx.AbsoluteSize.Y)
			end,

			ref = gradientRef,
		}, {
			UIGradient = React.createElement("UIGradient", {
				Color = Keypoints.toSequence(props.Keypoints),
			}),
			Overlay = React.createElement("Frame", {
				Size = UDim2.fromScale(1, 1),
				BorderSizePixel = 0,
				BackgroundColor3 = theme:GetColor(Enum.StudioStyleGuideColor.MainBackground),
				BackgroundTransparency = 0.5,
				Visible = not not props.Disabled,
			}),
		}),

		Markers = React.createElement("Frame", {
			BackgroundTransparency = 1,
			Size = UDim2.fromScale(1, 1),
		}, markers),
	})
end

return KeypointTrack
