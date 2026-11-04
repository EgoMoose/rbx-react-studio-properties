local uiRoot = script:FindFirstAncestor("UserInterface")
local NumberBox = require(uiRoot.Components.Properties.Foundational.NumberBox)
local ColorPicker = require(uiRoot.Components.ColorPicker)
local useColorPickerDock = require(uiRoot.Hooks.useColorPickerDock)
local Observables = require(uiRoot.Observables)

local pkgs = uiRoot.Parent.Parent
local StudioComponents = require(pkgs.StudioComponents)
local ReactRoblox = require(pkgs.ReactRoblox)
local React = require(pkgs.React)

local Keypoints = require(script.Keypoints)
local KeypointTrack = require(script.KeypointTrack)

local ROW_HEIGHT = 22
local BUTTON_WIDTH = 76

export type Props = {
	AnchorPoint: Vector2?,
	Position: UDim2?,
	Size: UDim2?,

	Value: ColorSequence,
	OnValueChanged: (ColorSequence) -> ()?,
	OnValueSubmitted: (ColorSequence) -> ()?,

	Disabled: boolean?,
}

local function Label(props: { Text: string, Width: number, LayoutOrder: number, Disabled: boolean? })
	local theme = StudioComponents.useTheme()
	return React.createElement("TextLabel", {
		BackgroundTransparency = 1,
		Size = UDim2.new(0, props.Width, 1, 0),
		FontFace = Font.fromName("SourceSansPro"),
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Center,
		TextColor3 = theme:GetColor(
			Enum.StudioStyleGuideColor.MainText,
			if props.Disabled then Enum.StudioStyleGuideModifier.Disabled else nil
		),
		Text = props.Text,
		TextSize = 14,
		LayoutOrder = props.LayoutOrder,
	})
end

local function Spacer(props: { Width: number, LayoutOrder: number })
	return React.createElement("Frame", {
		BackgroundTransparency = 1,
		Size = UDim2.new(0, props.Width, 1, 0),
		LayoutOrder = props.LayoutOrder,
	})
end

local function ColorSequencePicker(props: Props)
	local theme = StudioComponents.useTheme()

	local initialValueRef = React.useRef(props.Value)
	local lastValueRef = React.useRef(props.Value)

	local keypoints, setKeypointsState = React.useState(function()
		return Keypoints.fromSequence(props.Value)
	end)
	local keypointsRef = React.useRef(keypoints)

	local selectedId, setSelectedId = React.useState(keypoints[1].Id)
	local selected = Keypoints.find(keypoints, selectedId) or keypoints[1]

	local colorPickerOpen, colorPickerDock, setColorPickerOpen = useColorPickerDock()
	local anyColorPickerOpen = Observables.colorPickerOpen:use()
	local disabled = props.Disabled or anyColorPickerOpen

	local editingIdRef = React.useRef(nil :: number?)
	local prevColorRef = React.useRef(Color3.new())
	local colorPickerOpenRef = React.useRef(colorPickerOpen)
	colorPickerOpenRef.current = colorPickerOpen

	local function setKeypoints(newKeypoints: { Keypoints.Keypoint }, emit: boolean)
		Keypoints.sort(newKeypoints)
		keypointsRef.current = newKeypoints
		setKeypointsState(newKeypoints)

		local sequence = Keypoints.toSequence(newKeypoints)
		lastValueRef.current = sequence
		if emit and props.OnValueChanged then
			props.OnValueChanged(sequence)
		end
	end

	local function updateKeypoint(id: number, time: number?, color: Color3?)
		local current = keypointsRef.current
		local keypoint, index = Keypoints.find(current, id)
		if not (keypoint and index) then
			return
		end

		local newTime = if time and not keypoint.Edge then math.clamp(time, 0, 1) else keypoint.Time
		local newColor = color or keypoint.Color
		if newTime == keypoint.Time and newColor == keypoint.Color then
			return
		end

		local copy = table.clone(current)
		local newKeypoint = table.clone(keypoint)
		newKeypoint.Time = newTime
		newKeypoint.Color = newColor
		copy[index] = newKeypoint
		setKeypoints(copy, true)
	end

	local function addKeypoint(time: number): number?
		local current = keypointsRef.current
		if #current >= Keypoints.MAX_KEYPOINTS then
			return nil
		end

		local keypoint = Keypoints.new(time, Keypoints.evaluate(current, time))
		local copy = table.clone(current)
		table.insert(copy, keypoint)
		setKeypoints(copy, true)
		setSelectedId(keypoint.Id)
		return keypoint.Id
	end

	local function deleteKeypoint(id: number)
		local current = keypointsRef.current
		local keypoint, index = Keypoints.find(current, id)
		if not (keypoint and index) or keypoint.Edge then
			return
		end

		local copy = table.clone(current)
		table.remove(copy, index)
		setKeypoints(copy, true)
		setSelectedId(copy[math.min(index, #copy)].Id)
	end

	React.useEffect(function()
		if props.Value ~= lastValueRef.current then
			local _, index = Keypoints.find(keypointsRef.current, selectedId)
			local newKeypoints = Keypoints.fromSequence(props.Value)
			setKeypoints(newKeypoints, false)
			setSelectedId(newKeypoints[math.min(index or 1, #newKeypoints)].Id)
		end
	end, { props.Value })

	React.useEffect(function()
		local editingId = editingIdRef.current
		if not colorPickerOpen and editingId then
			editingIdRef.current = nil
			updateKeypoint(editingId, nil, prevColorRef.current)
		end
	end, { colorPickerOpen })

	React.useEffect(function()
		return function()
			if colorPickerOpenRef.current then
				Observables.colorPickerOpen:set(false)
			end
		end
	end, {})

	local editingKeypoint = Keypoints.find(keypoints, editingIdRef.current)

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
				PaddingLeft = UDim.new(0, 12),
				PaddingRight = UDim.new(0, 12),
				PaddingTop = UDim.new(0, 12),
				PaddingBottom = UDim.new(0, 10),
			}),

			Track = React.createElement(KeypointTrack, {
				Size = UDim2.new(1, 0, 1, -(ROW_HEIGHT + 14)),

				Keypoints = keypoints,
				SelectedId = selected.Id,

				OnSelect = setSelectedId,
				OnAdd = addKeypoint,
				OnMove = function(id, time)
					updateKeypoint(id, time, nil)
				end,

				Disabled = disabled,
			}),

			Controls = React.createElement("Frame", {
				BackgroundTransparency = 1,
				AnchorPoint = Vector2.new(0, 1),
				Position = UDim2.fromScale(0, 1),
				Size = UDim2.new(1, 0, 0, ROW_HEIGHT),
			}, {
				Left = React.createElement("Frame", {
					BackgroundTransparency = 1,
					Size = UDim2.new(1, -(BUTTON_WIDTH * 2 + 12), 1, 0),
				}, {
					UIListLayout = React.createElement("UIListLayout", {
						SortOrder = Enum.SortOrder.LayoutOrder,
						FillDirection = Enum.FillDirection.Horizontal,
						VerticalAlignment = Enum.VerticalAlignment.Center,
						Padding = UDim.new(0, 6),
					}),

					TimeLabel = React.createElement(Label, {
						Text = "Time",
						Width = 28,
						LayoutOrder = 1,
						Disabled = disabled or selected.Edge ~= nil,
					}),

					TimeInput = React.createElement("Frame", {
						BackgroundColor3 = theme:GetColor(Enum.StudioStyleGuideColor.MainBackground),
						BorderColor3 = theme:GetColor(Enum.StudioStyleGuideColor.Border),
						Size = UDim2.new(0, 90, 1, 0),
						LayoutOrder = 2,
					}, {
						Input = React.createElement(NumberBox, {
							Size = UDim2.fromScale(1, 1),

							Value = selected.Time,
							OnValueSubmitted = function(time)
								updateKeypoint(selected.Id, time, nil)
							end,

							Min = 0,
							Max = 1,
							Step = 0.001,
							StepButtonsDisabled = true,

							HighlightMode = "TextboxFocused",
							HighlightOnFocus = true,
							Disabled = disabled or selected.Edge ~= nil,
						}),
					}),

					Spacer1 = React.createElement(Spacer, { Width = 24, LayoutOrder = 3 }),

					ColorLabel = React.createElement(Label, {
						Text = "Color",
						Width = 32,
						LayoutOrder = 4,
						Disabled = disabled,
					}),

					ColorSwatch = React.createElement("ImageButton", {
						BorderColor3 = theme:GetColor(Enum.StudioStyleGuideColor.Border),
						BackgroundColor3 = selected.Color,
						AutoButtonColor = not disabled,
						Image = "",
						Size = UDim2.fromOffset(ROW_HEIGHT - 2, ROW_HEIGHT - 2),
						LayoutOrder = 5,

						[React.Event.Activated] = function()
							if not disabled and colorPickerDock then
								editingIdRef.current = selected.Id
								prevColorRef.current = selected.Color
								setColorPickerOpen(true)
							end
						end,
					}, {
						DisabledOverlay = disabled and React.createElement("Frame", {
							BorderSizePixel = 0,
							BackgroundTransparency = 0.5,
							BackgroundColor3 = theme:GetColor(
								Enum.StudioStyleGuideColor.ButtonText,
								Enum.StudioStyleGuideModifier.Disabled
							),
							Size = UDim2.fromScale(1, 1),
						}),
					}),

					Spacer2 = React.createElement(Spacer, { Width = 24, LayoutOrder = 6 }),

					Delete = React.createElement(StudioComponents.Button, {
						Size = UDim2.new(0, BUTTON_WIDTH, 1, 0),
						Text = "Delete",
						LayoutOrder = 7,

						OnActivated = function()
							deleteKeypoint(selected.Id)
						end,

						Disabled = disabled or selected.Edge ~= nil,
					}),
				}),

				Right = React.createElement("Frame", {
					BackgroundTransparency = 1,
					AnchorPoint = Vector2.new(1, 0),
					Position = UDim2.fromScale(1, 0),
					Size = UDim2.new(0, BUTTON_WIDTH * 2 + 6, 1, 0),
				}, {
					UIListLayout = React.createElement("UIListLayout", {
						SortOrder = Enum.SortOrder.LayoutOrder,
						FillDirection = Enum.FillDirection.Horizontal,
						VerticalAlignment = Enum.VerticalAlignment.Center,
						HorizontalAlignment = Enum.HorizontalAlignment.Right,
						Padding = UDim.new(0, 6),
					}),

					Reset = React.createElement(StudioComponents.Button, {
						Size = UDim2.new(0, BUTTON_WIDTH, 1, 0),
						Text = "Reset",
						LayoutOrder = 1,

						OnActivated = function()
							local _, index = Keypoints.find(keypointsRef.current, selected.Id)
							local newKeypoints = Keypoints.fromSequence(initialValueRef.current)
							setKeypoints(newKeypoints, true)
							setSelectedId(newKeypoints[math.min(index or 1, #newKeypoints)].Id)
						end,

						Disabled = disabled,
					}),

					Close = React.createElement(StudioComponents.Button, {
						Size = UDim2.new(0, BUTTON_WIDTH, 1, 0),
						Text = "Close",
						LayoutOrder = 2,

						OnActivated = function()
							if props.OnValueSubmitted then
								props.OnValueSubmitted(Keypoints.toSequence(keypointsRef.current))
							end
						end,

						Disabled = disabled,
					}),
				}),
			}),
		}),

		ColorPicker = colorPickerOpen and colorPickerDock and editingKeypoint and ReactRoblox.createPortal(
			React.createElement(ColorPicker, {
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.fromScale(0.5, 0.5),
				Size = UDim2.fromScale(1, 1),

				Value = editingKeypoint.Color,
				OnValueChanged = function(newColor)
					updateKeypoint(editingKeypoint.Id, nil, newColor)
				end,
				OnValueSubmitted = function(newColor)
					editingIdRef.current = nil
					updateKeypoint(editingKeypoint.Id, nil, newColor or prevColorRef.current)
					setColorPickerOpen(false)
				end,

				Disabled = false,
			}),
			colorPickerDock
		),
	})
end

return ColorSequencePicker
