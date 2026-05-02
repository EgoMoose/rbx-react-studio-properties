local SelectionService = game:GetService("Selection") :: Selection

local uiRoot = script:FindFirstAncestor("UserInterface")
local usePlugin = require(uiRoot.Hooks.usePlugin)

local pkgs = uiRoot.Parent.Parent
local StudioComponents = require(pkgs.StudioComponents)
local Lucide = require(pkgs.Lucide)
local React = require(pkgs.React)
local Trove = require(pkgs.Trove)

local foundationalRoot = script.Parent.Parent.Foundational
local PropertyLine = require(foundationalRoot.PropertyLine)
local Constants = require(foundationalRoot.Constants)

local CLEAR_ICON = assert(Lucide.GetAsset("trash", 16))

export type Props = {
	AnchorPoint: Vector2?,
	Position: UDim2?,

	FieldName: string,

	Value: Instance?,
	OnValueSubmitted: (Instance?) -> ()?,

	Indent: number?,
	LayoutOrder: number?,
	ZIndex: number?,
	Disabled: boolean?,

	children: React.ReactNode?,
}

local function useInstanceSelector()
	local plugin = usePlugin()
	local troveRef = React.useRef(Trove.new())

	local cancel = React.useCallback(function()
		troveRef.current:Clean()
	end, {})

	local listen = React.useCallback(function(input: InputObject, resolve: (Instance) -> ())
		if plugin then
			-- this helps us select in the viewport, but not mandatory
			plugin:SelectRibbonTool(Enum.RibbonTool.Select, UDim2.fromOffset(0, 0))
		end

		SelectionService:Set({})

		troveRef.current:Clean()
		troveRef.current:Add(SelectionService.SelectionChanged:Connect(function()
			local selected = SelectionService:Get()
			if #selected == 1 then
				resolve(selected[1])
			end
		end))

		troveRef.current:Add(input:GetPropertyChangedSignal("UserInputState"):Connect(function()
			if input.UserInputState == Enum.UserInputState.Begin then
				cancel()
			end
		end))
	end, { plugin })

	return React.useMemo(function()
		return {
			listen = listen,
			cancel = cancel,
		}
	end, { listen, cancel })
end

local function InstanceProperty(props: Props)
	local theme = StudioComponents.useTheme()
	local editingEnabled, setEditingEnabled = React.useState(false)
	local instanceSelector = useInstanceSelector()

	local instanceName, setInstanceName = React.useState(if props.Value then props.Value.Name else "")
	React.useEffect(function()
		setInstanceName(if props.Value then props.Value.Name else "")

		local connection
		if props.Value then
			connection = props.Value:GetPropertyChangedSignal("Name"):Connect(function()
				setInstanceName(props.Value.Name)
			end)
		end

		return function()
			if connection then
				connection:Disconnect()
			end
		end
	end, { props.Value })

	React.useEffect(function()
		instanceSelector.cancel()
	end, { props.Disabled })

	React.useEffect(function()
		return function()
			-- if the component un-renders
			instanceSelector.cancel()
		end
	end, {})

	return React.createElement(PropertyLine, {
		AnchorPoint = props.AnchorPoint,
		Position = props.Position,

		FieldName = props.FieldName,

		OnFocusLost = function()
			setEditingEnabled(false)
		end,

		OnActivated = function(input)
			instanceSelector.listen(input, function(instance)
				if props.OnValueSubmitted then
					props.OnValueSubmitted(instance)
				end
				setEditingEnabled(false)
			end)

			setEditingEnabled(true)
		end,

		Indent = props.Indent,
		LayoutOrder = props.LayoutOrder,
		ZIndex = props.ZIndex,
		Disabled = props.Disabled,

		Interface = React.createElement(React.Fragment, nil, {
			Content = React.createElement("Frame", {
				Active = false,
				BackgroundTransparency = 1,
				Size = UDim2.fromScale(1, 1),
			}, {
				EditingFrame = React.createElement("Frame", {
					Active = false,
					BackgroundTransparency = 1,
					Size = UDim2.fromScale(1, 1),
					Visible = editingEnabled,
				}, {
					DisplayLabel = React.createElement("TextLabel", {
						ClipsDescendants = true,
						BorderSizePixel = 0,
						BackgroundColor3 = theme:GetColor(
							Enum.StudioStyleGuideColor.InputFieldBackground,
							Enum.StudioStyleGuideModifier.Selected
						),
						Size = UDim2.new(1, -Constants.LineHeight, 1, 0),
						FontFace = Font.fromName("SourceSansPro"),
						TextYAlignment = Enum.TextYAlignment.Center,
						TextXAlignment = Enum.TextXAlignment.Left,
						TextTruncate = Enum.TextTruncate.AtEnd,
						TextColor3 = theme:GetColor(
							Enum.StudioStyleGuideColor.MainText,
							if props.Disabled then Enum.StudioStyleGuideModifier.Disabled else nil
						),
						Text = instanceName,
						TextSize = 14,
					}, {
						UIPadding = React.createElement("UIPadding", {
							PaddingLeft = UDim.new(0, 4),
							PaddingRight = UDim.new(0, 4),
						}),
					}),

					ClearButton = React.createElement("ImageButton", {
						Position = UDim2.new(1, -Constants.LineHeight, 0, 0),
						Size = UDim2.new(0, Constants.LineHeight, 1, 0),
						BorderSizePixel = 0,
						BackgroundColor3 = theme:GetColor(
							Enum.StudioStyleGuideColor.InputFieldBackground,
							Enum.StudioStyleGuideModifier.Selected
						),

						[React.Event.Activated] = function()
							instanceSelector.cancel()
							if props.OnValueSubmitted then
								props.OnValueSubmitted(nil)
							end
							setEditingEnabled(false)
						end,
					}, {
						Icon = React.createElement("ImageLabel", {
							BackgroundTransparency = 1,
							AnchorPoint = Vector2.new(0.5, 0.5),
							Position = UDim2.new(0.5, 0, 0.5, 0),
							Size = UDim2.fromOffset(12, 12),
							Image = CLEAR_ICON.Url,
							ImageRectSize = CLEAR_ICON.ImageRectSize,
							ImageRectOffset = CLEAR_ICON.ImageRectOffset,
						}),
					}),
				}),

				DisplayLabel = React.createElement("TextLabel", {
					Visible = not editingEnabled,
					ClipsDescendants = true,
					BackgroundTransparency = 1,
					Size = UDim2.fromScale(1, 1),
					FontFace = Font.fromName("SourceSansPro"),
					TextYAlignment = Enum.TextYAlignment.Center,
					TextXAlignment = Enum.TextXAlignment.Left,
					TextTruncate = Enum.TextTruncate.AtEnd,
					TextColor3 = theme:GetColor(
						Enum.StudioStyleGuideColor.MainText,
						if props.Disabled then Enum.StudioStyleGuideModifier.Disabled else nil
					),
					Text = instanceName,
					TextSize = 14,
				}, {
					UIPadding = React.createElement("UIPadding", {
						PaddingLeft = UDim.new(0, 4),
						PaddingRight = UDim.new(0, 4),
					}),
				}),
			}),
		}) :: React.ReactNode,
	}, props.children)
end

return InstanceProperty
