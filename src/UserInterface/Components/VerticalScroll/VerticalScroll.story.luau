local uiRoot = script:FindFirstAncestor("UserInterface")
local CreateStory = require(uiRoot.Stories.CreateStory)

local pkgs = uiRoot.Parent.Parent
local StudioComponents = require(pkgs.StudioComponents)
local ReactRoblox = require(pkgs.ReactRoblox)
local React = require(pkgs.React)

local VerticalScroll = require(script.Parent)

type Props = {
	Disabled: boolean?,
}

local function Widget(props: Props)
	local children: { [string]: React.ReactNode } = {}
	for i = 1, 20 do
		children["Frame" .. i] = React.createElement("Frame", {
			Size = UDim2.fromOffset(100, 100),
			LayoutOrder = i,
		})
	end

	return React.createElement("Frame", {
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(1, 1),
		ClipsDescendants = true,
		ZIndex = -1, -- Fixes dropdown issues
	}, {
		Content = React.createElement(VerticalScroll, {
			Size = UDim2.fromScale(1, 1),
			ScrollInset = UDim.new(0, -2),
			ScrollBarFades = true,
			Disabled = props.Disabled,
		}, {
			UIListLayout = React.createElement("UIListLayout", {
				FillDirection = Enum.FillDirection.Vertical,
				SortOrder = Enum.SortOrder.LayoutOrder,
				Padding = UDim.new(0, 0),
			}),
		}, children),
	})
end

return {
	react = React,
	reactRoblox = ReactRoblox,
	story = CreateStory(function(props)
		local theme = StudioComponents.useTheme()

		return React.createElement("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromOffset(300, 450),
			BackgroundColor3 = theme:GetColor(Enum.StudioStyleGuideColor.MainBackground),
			BorderColor3 = theme:GetColor(Enum.StudioStyleGuideColor.Border),
		}, {
			Core = React.createElement(Widget, {
				Disabled = props.controls.disabled,
			}),
		})
	end),
}
