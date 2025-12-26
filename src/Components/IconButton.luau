--!strict
local Fusion = require "@pkg/Fusion"
local Children = Fusion.Children
local OnEvent = Fusion.OnEvent
local peek = Fusion.peek
type Scope = Fusion.Scope<typeof(Fusion)>
type UsedAs<T> = Fusion.UsedAs<T>

local Theme = require "@conway/Theme"
local UseTheme = require "@conway/UseTheme"

type Callback = () -> ()
export type Icon = "pause" | "reset" | "resume" | "start" | "stop"
export type Props = {
    AnchorPoint: UsedAs<Vector2>?,
    Color: UsedAs<Enum.StudioStyleGuideColor>?,
    Disabled: UsedAs<boolean>?,
    Name: UsedAs<string>?,
    Parent: UsedAs<GuiBase2d?>?,
    Position: UsedAs<UDim2>?,
    Icon: UsedAs<Icon>,
    Size: UsedAs<UDim2>?,

    Clicked: Callback?,
}

local ICONS: { [Icon]: string } = {
    pause = "rbxasset://studio_svg_textures/Shared/Ribbon/%s/Standard/RibbonPauseSmall@3x.png",
    reset = "rbxasset://studio_svg_textures/Shared/Ribbon/%s/Standard/RotateSpinbox@3x.png",
    resume = "rbxasset://studio_svg_textures/Shared/Ribbon/%s/Standard/RibbonResumeSmall@3x.png",
    start = "rbxasset://studio_svg_textures/Shared/Ribbon/%s/Standard/RibbonPlaySmall@3x.png",
    stop = "rbxasset://studio_svg_textures/Shared/Ribbon/%s/Standard/RibbonStopActiveSmall@3x.png",
}
local PADDING = UDim.new(0, 4)

return function(scope: Scope, props: Props)
    assert(ICONS[peek(props.Icon)], "Invalid icon name provided to IconButton")

    local theme = Theme:now()

    local hovering = scope:Value(false)
    local pressed = scope:Value(false)
    local modifier = scope:Computed(function(use)
            if use(props.Disabled) then
                return Enum.StudioStyleGuideModifier.Disabled
            end

            if use(pressed) then
                return Enum.StudioStyleGuideModifier.Pressed
            end

            if use(hovering) then
                return Enum.StudioStyleGuideModifier.Hover
            end

            return Enum.StudioStyleGuideModifier.Default
        end)

    return scope:New "ImageButton" {
        Active = scope:Computed(function(use)
            return not use(props.Disabled)
        end),
        BackgroundColor3 = UseTheme(scope, props.Color or Enum.StudioStyleGuideColor.Button, modifier),
        BackgroundTransparency = 0,
        Name = props.Name or "IconButton",
        Size = props.Size,
        Position = props.Position or UDim2.fromOffset(0, 0),
        AnchorPoint = props.AnchorPoint or Vector2.new(0, 0),

        [OnEvent "Activated"] = props.Clicked,

        [OnEvent "MouseButton1Down"] = function()
            pressed:set(true)
        end,

        [OnEvent "MouseButton1Up"] = function()
            pressed:set(false)
        end,

        [OnEvent "MouseEnter"] = function()
            hovering:set(true)
        end,

        [OnEvent "MouseLeave"] = function()
            hovering:set(false)
            pressed:set(false)
        end,

        [Children] = {
            scope:New "UICorner" {
                CornerRadius = UDim.new(0, 4),
                Name = "Corner",
            },
            scope:New "UIAspectRatioConstraint" {
                AspectRatio = 1,
                AspectType = Enum.AspectType.FitWithinMaxSize,
                DominantAxis = Enum.DominantAxis.Height,
                Name = "Aspect Ratio",
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
                Image = scope:Computed(function(use)
                    return ICONS[use(props.Icon)]:format(use(theme).Name)
                end),
                ImageTransparency = scope:Computed(function(use)
                    return if use(props.Disabled) then 0.5 else 0
                end),
                Size = UDim2.fromScale(1, 1),
            }
        }
    }
end