local uiRoot = script:FindFirstAncestor("UserInterface")
local VerticalScroll = require(uiRoot.Components.VerticalScroll)
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
		Content = React.createElement(VerticalScroll, {
			Size = UDim2.fromScale(1, 1),
			ScrollBarTransparency = 0.7,
			ScrollInset = UDim.new(0, -2),
			ScrollBarFades = true,
			Disabled = props.Disabled,
		}, {
			UIListLayout = React.createElement("UIListLayout", {
				FillDirection = Enum.FillDirection.Vertical,
				SortOrder = Enum.SortOrder.LayoutOrder,
				Padding = UDim.new(0, 0),
			}),

			PrimitivesGroup = React.createElement(StudioProperties.PropertyGroup, {
				GroupName = "Primitives",
				ForceExpanded = true,
				Disabled = props.Disabled,
				LayoutOrder = 1,
			}, {
				UIListLayout = React.createElement("UIListLayout", {
					FillDirection = Enum.FillDirection.Vertical,
					SortOrder = Enum.SortOrder.LayoutOrder,
					Padding = UDim.new(0, 0),
				}),

				StringField = React.createElement(function()
					local value, setValue = React.useState("Hello")
					return React.createElement(StudioProperties.String, {
						FieldName = "String",

						Value = value,
						OnValueSubmitted = setValue,

						LayoutOrder = 1,
						Disabled = props.Disabled,
					})
				end),

				NumberField = React.createElement(function()
					local value, setValue = React.useState(1)
					return React.createElement(StudioProperties.Number, {
						FieldName = "Number",

						Value = value,
						OnValueSubmitted = setValue,

						Max = 100,
						Min = 0,
						Step = 0.1,
						Slider = true,

						LayoutOrder = 2,
						Disabled = props.Disabled,
					})
				end),

				BooleanField = React.createElement(function()
					local value, setValue = React.useState(false)
					return React.createElement(StudioProperties.Boolean, {
						FieldName = "Boolean",

						Value = value,
						OnValueSubmitted = setValue,

						LayoutOrder = 3,
						Disabled = props.Disabled,
					})
				end),

				DropdownField = React.createElement(function()
					local value, setValue = React.useState("ThingA")
					return React.createElement(StudioProperties.Dropdown, {
						FieldName = "Dropdown",

						Value = value,
						OnValueSubmitted = setValue,

						List = {
							"ThingA",
							"ThingB",
							"ThingC",
							"ThingD",
							"ThingE",
						},

						LayoutOrder = 4,
						Disabled = props.Disabled,
					})
				end),

				InstanceField = React.createElement(function()
					local value, setValue = React.useState(workspace :: Instance?)
					return React.createElement(StudioProperties.Instance, {
						FieldName = "Instance",

						Value = value,
						OnValueSubmitted = setValue,

						LayoutOrder = 5,
						Disabled = props.Disabled,
					})
				end),
			}),

			RobloxGroup = React.createElement(StudioProperties.PropertyGroup, {
				GroupName = "Roblox",
				Disabled = props.Disabled,
				LayoutOrder = 2,
			}, {
				UIListLayout = React.createElement("UIListLayout", {
					FillDirection = Enum.FillDirection.Vertical,
					SortOrder = Enum.SortOrder.LayoutOrder,
					Padding = UDim.new(0, 0),
				}),

				Vector2Field = React.createElement(function()
					local value, setValue = React.useState(Vector2.new(1, 2))
					return React.createElement(StudioProperties.Vector2, {
						FieldName = "Vector2",

						Value = value,
						OnValueSubmitted = setValue,

						LayoutOrder = 1,
						Disabled = props.Disabled,
					})
				end),

				Vector3Field = React.createElement(function()
					local value, setValue = React.useState(Vector3.new(1, 2, 3))
					return React.createElement(StudioProperties.Vector3, {
						FieldName = "Vector3",

						Value = value,
						OnValueSubmitted = setValue,

						LayoutOrder = 2,
						Disabled = props.Disabled,
					})
				end),

				UDimField = React.createElement(function()
					local value, setValue = React.useState(UDim.new(1, 10))
					return React.createElement(StudioProperties.UDim, {
						FieldName = "UDim",

						Value = value,
						OnValueSubmitted = setValue,

						LayoutOrder = 3,
						Disabled = props.Disabled,
					})
				end),

				UDim2Field = React.createElement(function()
					local value, setValue = React.useState(UDim2.new(1, 10, 1, 10))
					return React.createElement(StudioProperties.UDim2, {
						FieldName = "UDim2",
						ForceExpanded = false,

						Value = value,
						OnValueSubmitted = setValue,

						LayoutOrder = 4,
						Disabled = props.Disabled,
					})
				end),

				CFrameField = React.createElement(function()
					local value, setValue = React.useState(CFrame.identity)
					return React.createElement(StudioProperties.CFrame, {
						FieldName = "CFrame",
						ForceExpanded = true,

						Value = value,
						OnValueSubmitted = setValue,

						LayoutOrder = 5,
						Disabled = props.Disabled,
					})
				end),

				Color3Field = React.createElement(function()
					local value, setValue = React.useState(Color3.fromRGB(255, 20, 30))
					return React.createElement(StudioProperties.Color3, {
						FieldName = "Color3",

						Value = value,
						OnValueSubmitted = setValue,

						LayoutOrder = 6,
						Disabled = props.Disabled,
					})
				end),
				Color3Field2 = React.createElement(function()
					local value, setValue = React.useState(Color3.fromRGB(0, 255, 30))
					return React.createElement(StudioProperties.Color3, {
						FieldName = "Color3",

						Value = value,
						OnValueSubmitted = setValue,

						LayoutOrder = 7,
						Disabled = props.Disabled,
					})
				end),
			}),
		}),
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
