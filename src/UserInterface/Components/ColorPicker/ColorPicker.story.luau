local uiRoot = script:FindFirstAncestor("UserInterface")
local CreateStory = require(uiRoot.Stories.CreateStory)

local pkgs = uiRoot.Parent.Parent
local StudioComponents = require(pkgs.StudioComponents)
local ReactRoblox = require(pkgs.ReactRoblox)
local React = require(pkgs.React)

local ColorPicker = require(script.Parent)

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
				local color, setColor = React.useState(Color3.new(1, 1, 1))

				return React.createElement(ColorPicker, {
					AnchorPoint = Vector2.new(0.5, 0.5),
					Position = UDim2.fromScale(0.5, 0.5),
					Size = UDim2.fromOffset(520, 400),

					Value = color,
					OnValueSubmitted = function(newColor)
						if newColor then
							setColor(newColor)
						end
						print(newColor)
					end,

					Disabled = props.controls.disabled,
				})
			end),
		})
	end),
}
