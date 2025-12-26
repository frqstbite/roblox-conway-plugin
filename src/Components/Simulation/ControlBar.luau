--!strict
local Fusion = require "@pkg/Fusion"
local Children = Fusion.Children
local peek = Fusion.peek
type Scope = Fusion.Scope<typeof(Fusion)>
type UsedAs<T> = Fusion.UsedAs<T>

local IconButton = require "@conway/Components/IconButton"
local UseTheme = require "@conway/UseTheme"

local HEIGHT = 36
local PADDING = UDim.new(0, 6)

type Callback = () -> ()
export type Props = {
    Dirty: UsedAs<boolean>,
    LayoutOrder: UsedAs<number>?,
    Running: UsedAs<boolean>,
    Started: UsedAs<boolean>,

    Paused: Callback,
    Played: Callback,
    Reset: Callback,
    Resumed: Callback,
    Stopped: Callback,
}

return function(scope: Scope, props: Props)
    return scope:New "Frame" {
        BackgroundColor3 = UseTheme(scope, Enum.StudioStyleGuideColor.MainBackground),
        Name = "Control Bar",
        Size = UDim2.new(1, 0, 0, HEIGHT),

        [Children] = {
            scope:New "UIStroke" {
                ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
                BorderStrokePosition = Enum.BorderStrokePosition.Outer,
                Color = UseTheme(scope, Enum.StudioStyleGuideColor.MainText ),
                Name = "Stroke",
                StrokeSizingMode = Enum.StrokeSizingMode.FixedSize,
                Thickness = 1,
            },
            scope:New "UIPadding" {
                Name = "Padding",
                PaddingTop = PADDING,
                PaddingBottom = PADDING,
                PaddingLeft = PADDING,
                PaddingRight = PADDING,
            },
            scope:New "ImageLabel" {
                BackgroundTransparency = 1,
                Name = "Icon",
                Size = UDim2.fromScale(1, 1),
                Image = "rbxassetid://87371430812024",
                [Children] = scope:New "UIAspectRatioConstraint" {
                    AspectRatio = 1,
                    AspectType = Enum.AspectType.FitWithinMaxSize,
                    DominantAxis = Enum.DominantAxis.Height,
                    Name = "Aspect Ratio",
                }
            },
            scope:New "Frame" {
                AnchorPoint = Vector2.xAxis,
                AutomaticSize = Enum.AutomaticSize.X,
                BackgroundTransparency = 1,
                Name = "Controls",
                Position = UDim2.fromScale(1, 0),
                Size = UDim2.fromScale(0, 1),

                [Children] = {
                    scope:New "UIListLayout" {
                        Name = "List",
                        FillDirection = Enum.FillDirection.Horizontal,
                        HorizontalAlignment = Enum.HorizontalAlignment.Right,
                        HorizontalFlex = Enum.UIFlexAlignment.SpaceBetween,
                        ItemLineAlignment = Enum.ItemLineAlignment.Stretch,
                        Padding = PADDING,
                        Wraps = false,
                        VerticalAlignment = Enum.VerticalAlignment.Center,
                    },

                    -- Start/stop button
                    IconButton(scope, {
                        Color = Enum.StudioStyleGuideColor.RibbonButton,
                        Icon = scope:Computed(function(use): any
                            return if use(props.Started) then "stop" else "start"
                        end),
                        Size = UDim2.fromScale(1, 1),

                        Clicked = function()
                            (if peek(props.Started) then props.Stopped else props.Played)()
                        end,
                    }),

                    -- Pause/resume button
                    IconButton(scope, {
                        Color = Enum.StudioStyleGuideColor.RibbonButton,
                        Disabled = scope:Computed(function(use)
                            return not use(props.Started)
                        end),
                        Icon = scope:Computed(function(use): any
                            if use(props.Started) and not use(props.Running) then
                                return "resume"
                            end

                            return "pause"
                        end),
                        Size = UDim2.fromScale(1, 1),

                        Clicked = function()
                            (if peek(props.Running) then props.Paused else props.Resumed)()
                        end,
                    }),

                    -- Reset button
                    IconButton(scope, {
                        Color = Enum.StudioStyleGuideColor.RibbonButton,
                        Disabled = scope:Computed(function(use): any
                            return use(props.Running) or not use(props.Dirty) 
                        end),
                        Icon = "reset",
                        Size = UDim2.fromScale(1, 1),

                        Clicked = props.Reset,
                    }),
                }
            }
        },
    }
end