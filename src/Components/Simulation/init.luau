--!strict
local Fusion = require "@pkg/Fusion"
local Children = Fusion.Children
local peek = Fusion.peek
type Scope = Fusion.Scope<typeof(Fusion)>
type UsedAs<T> = Fusion.UsedAs<T>

local Bitmap = require "@conway/Components/Simulation/Bitmap"
local ControlBar = require "@conway/Components/Simulation/ControlBar"
local UseTheme = require "@conway/UseTheme"

export type Props = {
    AnchorPoint: UsedAs<Vector2>?,
    CanvasSize: UsedAs<Vector2>,
    CellSize: UsedAs<number>,
    Parent: UsedAs<GuiBase2d?>?,
    Position: UsedAs<UDim2>?,
    Size: UsedAs<UDim2>?,
}

return function(scope: Scope, props: Props)    

    -- Simulation state
    local running = scope:Value(false)
    local started = scope:Value(false)
    local cells = scope:Value({})
    local currentBoard

    return scope:New "Frame" {
        AnchorPoint = props.AnchorPoint,
        BackgroundTransparency = 1,
        Name = "Simulation",
        Size = props.Size or UDim2.fromScale(1, 1),
        Parent = props.Parent,
        Position = props.Position,

        [Children] = {
            scope:New "UIListLayout" {
                FillDirection = Enum.FillDirection.Vertical,
                HorizontalAlignment = Enum.HorizontalAlignment.Center,
                Name = "List",
                SortOrder = Enum.SortOrder.LayoutOrder,
                VerticalAlignment = Enum.VerticalAlignment.Top,
            },
            ControlBar(scope, {
                Dirty = scope:Computed(function(use)
                    return #use(cells) > 0
                end),
                LayoutOrder = 1,
                Running = running,
                Started = started,

                Paused = function()
                    running:set(false)
                end,

                Played = function()
                    started:set(true)
                    running:set(true)
                    currentBoard = table.clone(peek(cells))
                end,
                
                Reset = function()
                    local c = peek(cells)
                    table.clear(c)
                    cells:set(c)
                end,

                Resumed = function()
                    running:set(true)
                end,

                Stopped = function()
                    started:set(false)
                    running:set(false)
                    cells:set(currentBoard)
                end,    
            }),
            Bitmap(scope, {
                Background = UseTheme(scope, Enum.StudioStyleGuideColor.ScriptBackground),
                Cells = cells,
                CellSize = props.CellSize,
                Color = UseTheme(scope, Enum.StudioStyleGuideColor.LinkText),
                Drawable = true,
                LayoutOrder = 2,
                Size = UDim2.fromScale(1, 1),

                AddCell = function(x, y)
                    local c = peek(cells)

                    local exists = table.find(c, Vector2.new(x, y))
                    if exists then
                        table.remove(c, exists)
                    else
                        table.insert(c, Vector2.new(x, y))
                    end

                    cells:set(c)
                end,
            }),
        },
    }
end