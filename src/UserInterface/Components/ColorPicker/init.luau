local uiRoot = script:FindFirstAncestor("UserInterface")
local Observables = require(uiRoot.Observables)

local pkgs = uiRoot.Parent.Parent
local StudioComponents = require(pkgs.StudioComponents)
local React = require(pkgs.React)

local DefaultColors = require(script.DefaultColors)
local ColorSwatches = require(script.ColorSwatches)
local TextInputs = require(script.TextInputs)
local HSVPicker = require(script.HSVPicker)

export type Props = {
	AnchorPoint: Vector2?,
	Position: UDim2?,
	Size: UDim2?,

	Value: Color3,
	OnValueChanged: (Color3) -> ()?,
	OnValueSubmitted: (Color3?) -> ()?,

	Disabled: boolean?,
}

local function ColorPicker(props: Props)
	local theme = StudioComponents.useTheme()
	local customColors = Observables.customColors:use()
	local hsv, setHSVRaw = React.useState({ props.Value:ToHSV() })
	local color = Color3.fromHSV(hsv[1], hsv[2], hsv[3])

	local function setHSV(newHSV: { number })
		setHSVRaw(newHSV)
		if not (newHSV[1] == hsv[1] and newHSV[2] == hsv[2] and newHSV[3] == hsv[3]) then
			local newColor = Color3.fromHSV(newHSV[1], newHSV[2], newHSV[3])
			if props.OnValueChanged then
				props.OnValueChanged(newColor)
			end
		end
	end

	React.useEffect(function()
		local newHSV = { props.Value:ToHSV() }
		if color ~= props.Value and not (newHSV[1] == hsv[1] and newHSV[2] == hsv[2] and newHSV[3] == hsv[3]) then
			setHSV(newHSV)
		end
	end, { props.Value })

	return React.createElement(StudioComponents.Background, {
		AnchorPoint = props.AnchorPoint,
		Position = props.Position,
		Size = props.Size,
	}, {
		Clipping = React.createElement("Frame", {
			BackgroundTransparency = 1,
			Size = UDim2.fromScale(1, 1),
			ClipsDescendants = true,
		}, {
			UIPadding = React.createElement("UIPadding", {
				PaddingLeft = UDim.new(0, 10),
				PaddingRight = UDim.new(0, 10),
				PaddingTop = UDim.new(0, 10),
				PaddingBottom = UDim.new(0, 10),
			}),

			Content = React.createElement("Frame", {
				BackgroundTransparency = 1,
				Size = UDim2.new(1, 0, 1, -36),
			}, {
				Swatches = React.createElement("Frame", {
					BackgroundTransparency = 1,
					Size = UDim2.new(0, 218, 1, 0),
				}, {
					UIListLayout = React.createElement("UIListLayout", {
						FillDirection = Enum.FillDirection.Vertical,
						SortOrder = Enum.SortOrder.LayoutOrder,
						Padding = UDim.new(0, 16),
					}),

					BasicColors = React.createElement("Frame", {
						BackgroundTransparency = 1,
						Size = UDim2.new(1, 0, 0, 24 + 138),
						LayoutOrder = 1,
					}, {
						Title = React.createElement("TextLabel", {
							BackgroundTransparency = 1,
							Size = UDim2.new(1, 0, 0, 24),
							FontFace = Font.fromName("SourceSansPro"),
							TextYAlignment = Enum.TextYAlignment.Top,
							TextXAlignment = Enum.TextXAlignment.Left,
							TextTruncate = Enum.TextTruncate.AtEnd,
							TextColor3 = theme:GetColor(
								Enum.StudioStyleGuideColor.MainText,
								if props.Disabled then Enum.StudioStyleGuideModifier.Disabled else nil
							),
							Text = "Basic Colors",
							TextSize = 14,
						}),

						Swatches = React.createElement(ColorSwatches, {
							Position = UDim2.fromOffset(0, 24),
							Size = UDim2.new(1, 0, 0, 138),

							Colors = DefaultColors,
							OnActivated = function(newColor)
								setHSV({ newColor:ToHSV() })
							end,

							Disabled = props.Disabled,
						}),
					}),
					CustomColors = React.createElement("Frame", {
						BackgroundTransparency = 1,
						Size = UDim2.new(1, 0, 0, 24 + 42 + 36),
						LayoutOrder = 2,
					}, {
						Title = React.createElement("TextLabel", {
							BackgroundTransparency = 1,
							Size = UDim2.new(1, 0, 0, 24),
							FontFace = Font.fromName("SourceSansPro"),
							TextYAlignment = Enum.TextYAlignment.Top,
							TextXAlignment = Enum.TextXAlignment.Left,
							TextTruncate = Enum.TextTruncate.AtEnd,
							TextColor3 = theme:GetColor(
								Enum.StudioStyleGuideColor.MainText,
								if props.Disabled then Enum.StudioStyleGuideModifier.Disabled else nil
							),
							Text = "Custom Colors",
							TextSize = 14,
						}),

						Swatches = React.createElement(ColorSwatches, {
							Position = UDim2.fromOffset(0, 24),
							Size = UDim2.new(1, 0, 0, 42),

							Colors = customColors,
							OnActivated = function(newColor)
								setHSV({ newColor:ToHSV() })
							end,

							Disabled = props.Disabled,
						}),

						Button = React.createElement(StudioComponents.Button, {
							AnchorPoint = Vector2.new(0.5, 1),
							Position = UDim2.new(0.5, 0, 1, -1),
							Size = UDim2.new(1, -2, 0, 26),
							Text = "Add to Custom Colors",

							OnActivated = function()
								local copy = table.clone(customColors)
								table.remove(copy) -- pop off the oldest
								table.insert(copy, 1, color) -- add the new at the front
								Observables.customColors:set(copy)
							end,

							Disabled = props.Disabled,
						}),
					}),
				}),

				Advanced = React.createElement("Frame", {
					BackgroundTransparency = 1,
					AnchorPoint = Vector2.new(1, 0),
					Position = UDim2.fromScale(1, 0),
					Size = UDim2.new(0, 262, 1, 0),
				}, {
					Picker = React.createElement(HSVPicker, {
						Position = UDim2.fromOffset(0, 10),
						Size = UDim2.new(1, 0, 0, 200),

						HSV = hsv,
						SetHSV = setHSV,

						Disabled = props.Disabled,
					}),

					Under = React.createElement("Frame", {
						BackgroundTransparency = 1,
						Position = UDim2.fromOffset(0, 232),
						Size = UDim2.new(1, 0, 1, -232),
					}, {
						DisplayColor = React.createElement("Frame", {
							BorderSizePixel = 1,
							BorderColor3 = theme:GetColor(Enum.StudioStyleGuideColor.Border),
							BackgroundColor3 = color,
							Size = UDim2.new(0, 58, 1, 0),
						}, {
							DisabledOverlay = props.Disabled and React.createElement("Frame", {
								BorderSizePixel = 0,
								BackgroundTransparency = 0.5,
								BackgroundColor3 = theme:GetColor(
									Enum.StudioStyleGuideColor.ButtonText,
									Enum.StudioStyleGuideModifier.Disabled
								),
								Size = UDim2.fromScale(1, 1),
							}),
						}),

						Inputs = React.createElement(TextInputs, {
							AnchorPoint = Vector2.new(1, 0),
							Position = UDim2.fromScale(1, 0),
							Size = UDim2.new(1, -68, 1, 0),

							HSV = hsv,
							SetHSV = setHSV,

							Disabled = props.Disabled,
						}),
					}),
				}),
			}),

			Buttons = React.createElement("Frame", {
				BackgroundTransparency = 1,
				AnchorPoint = Vector2.new(0, 1),
				Position = UDim2.fromScale(0, 1),
				Size = UDim2.new(1, 0, 0, 26),
			}, {
				UIListLayout = React.createElement("UIListLayout", {
					SortOrder = Enum.SortOrder.LayoutOrder,
					FillDirection = Enum.FillDirection.Horizontal,
					VerticalAlignment = Enum.VerticalAlignment.Center,
					HorizontalAlignment = Enum.HorizontalAlignment.Right,
					Padding = UDim.new(0, 6),
				}),

				Cancel = React.createElement(StudioComponents.Button, {
					Size = UDim2.new(0, 76, 1, 0),
					Text = "Cancel",
					LayoutOrder = -1,

					OnActivated = function()
						if props.OnValueSubmitted then
							props.OnValueSubmitted(nil)
						end
					end,

					Disabled = props.Disabled,
				}),

				Confirm = React.createElement(StudioComponents.MainButton, {
					Size = UDim2.new(0, 76, 1, 0),
					Text = "Ok",
					LayoutOrder = -2,

					OnActivated = function()
						if props.OnValueSubmitted then
							props.OnValueSubmitted(color)
						end
					end,

					Disabled = props.Disabled,
				}),
			}),
		}),
	})
end

return ColorPicker
