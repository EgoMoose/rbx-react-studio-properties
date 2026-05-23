local uiRoot = script:FindFirstAncestor("UserInterface")
local CreateStory = require(uiRoot.Stories.CreateStory)
local StudioProperties = require(uiRoot.Parent)

local pkgs = uiRoot.Parent.Parent
local StudioComponents = require(pkgs.StudioComponents)
local ReactRoblox = require(pkgs.ReactRoblox)
local React = require(pkgs.React)

type Props = {
	Disabled: boolean?,
}

local function Widget(props: Props)
	return React.createElement("Frame", {
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(1, 1),
		ClipsDescendants = true,
		ZIndex = -1, -- Fixes dropdown issues
	}, {
		UIListLayout = React.createElement("UIListLayout", {
			FillDirection = Enum.FillDirection.Vertical,
			SortOrder = Enum.SortOrder.LayoutOrder,
			Padding = UDim.new(0, 4),
		}),

		StringBox = React.createElement(function()
			local value, setValue = React.useState("Hello world!")

			return React.createElement(StudioProperties.StringBox, {
				Size = UDim2.new(1, 0, 0, 22),
				LayoutOrder = 1,

				Value = value,
				OnValueSubmitted = setValue,
				HighlightOnFocus = true,
			})
		end),

		NumberBox = React.createElement(function()
			local value, setValue = React.useState(0)

			return React.createElement(StudioProperties.NumberBox, {
				Size = UDim2.new(1, 0, 0, 22),
				LayoutOrder = 2,

				Value = value,
				OnValueSubmitted = setValue,
				HighlightOnFocus = true,
			})
		end),

		StringBoxNoFocusHighlight = React.createElement(function()
			local value, setValue = React.useState("No Focus Highlight!")

			return React.createElement(StudioProperties.StringBox, {
				Size = UDim2.new(1, 0, 0, 22),
				LayoutOrder = 3,

				Value = value,
				OnValueSubmitted = setValue,
				HighlightOnFocus = false,
			})
		end),

		NumberBoxNoStepper = React.createElement(function()
			local value, setValue = React.useState(0)

			return React.createElement(StudioProperties.NumberBox, {
				Size = UDim2.new(1, 0, 0, 22),
				LayoutOrder = 4,

				Step = 1,
				StepButtonsDisabled = true,

				Value = value,
				OnValueSubmitted = setValue,
				HighlightOnFocus = true,
			})
		end),
	})
end

local UILabs = require(game.ReplicatedStorage.DevPackages.UILabs)

local Studio = settings().Studio
local themes = Studio:GetAvailableThemes()

return {
	react = React,
	reactRoblox = ReactRoblox,

	controls = {
		disabled = false,
		theme = UILabs.Choose({ "Default", "Dark", "Light" }),
	},

	story = CreateStory(function(props)
		local rootTheme = nil
		if props.controls.theme == "Dark" then
			rootTheme = themes[2]
		elseif props.controls.theme == "Light" then
			rootTheme = themes[1]
		end

		return React.createElement(StudioComponents.ThemeContext.Provider, {
			value = rootTheme,
		}, {
			Story = React.createElement(function()
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
		})
	end),
}
