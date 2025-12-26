--!strict
local UserInputService = game:GetService("UserInputService") :: UserInputService

local Fusion = require "@pkg/Fusion"
local Children = Fusion.Children
local OnEvent = Fusion.OnEvent
local Out = Fusion.Out
local peek = Fusion.peek
type Scope = Fusion.Scope<typeof(Fusion)>
type UsedAs<T> = Fusion.UsedAs<T>
type Value<T> = Fusion.Value<T>

local ObjectPool = require "@pkg/ObjectPool"
type ObjectPool<T> = ObjectPool.ObjectPool<T>

type Callback = () -> ()
export type Props = {
    Background: UsedAs<Color3>,
    Cells: UsedAs<{Vector2}>,
    CellSize: UsedAs<number>,
    Color: UsedAs<Color3>,
    Drawable: UsedAs<boolean>,
    LayoutOrder: UsedAs<number>?,
    Name: UsedAs<string>?,
    Size: UsedAs<UDim2>,

    AddCell: (number, number) -> (),
}

local CELLS_MINIMUM = 100

local function getCell(x: number, y: number, size: number): Vector2
    return Vector2.new(math.floor(x / size), math.floor(y / size))
end

return function(scope: Scope, props: Props)
    -- Pool cell frames because we'll be manipulating them frequently and don't need to waste time creating new instances
    local cellpool: ObjectPool<Frame> = ObjectPool.new(function()
        return scope:New "Frame" {
            Active = false,
            AnchorPoint = Vector2.zero,
            BackgroundColor3 = props.Color,
            Name = "Cell",
            Size = scope:Computed(function(use)
                local size = use(props.CellSize)
                return UDim2.fromOffset(size, size)
            end),
        } :: Frame
    end, CELLS_MINIMUM)

    local held: Value<boolean> = scope:Value(false)
    local inside: Value<boolean> = scope:Value(false)
    local mouse: Value<Vector2> = scope:Value(Vector2.zero)
    local pos: Value<Vector2> = scope:Value(Vector2.zero)

    local drawing = scope:Computed(function(use)
        return use(props.Drawable) and use(held)
    end)

    local selectedCell = scope:Computed(function(use)
        local vec = use(mouse) - use(pos)
        return getCell(vec.X, vec.Y, use(props.CellSize))
    end)

    return scope:New "Frame" {
        BackgroundColor3 = props.Background,
        Name = props.Name or "Bitmap",
        LayoutOrder = props.LayoutOrder,
        Size = props.Size,

        [OnEvent "InputBegan"] = function(input: InputObject, handled)
            print"b"
            if not handled and input.UserInputType == Enum.UserInputType.MouseButton1 then
                held:set(true)
            end
        end,

        [OnEvent "InputEnded"] = function(input: InputObject)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                held:set(false)
            end
        end,
        
        [OnEvent "MouseEnter"] = function()
            inside:set(true)
        end,
        
        [OnEvent "MouseLeave"] = function()
            held:set(false)
            inside:set(false)
        end,

        [OnEvent "MouseMoved"] = function(x: number, y: number)
            local size = peek(props.CellSize)
            local vec = Vector2.new(x, y) - peek(pos)

            -- Draw pixel, if allowed
            local cell = getCell(vec.X, vec.Y, size)
            if peek(drawing) and cell ~= peek(selectedCell) then
                props.AddCell(cell.X, cell.Y)
            end
            
            -- Update mouse position
            mouse:set(Vector2.new(x, y))
        end,

        [Out "AbsolutePosition"] = pos,

        [Children] = scope:ForValues(props.Cells, function(use, scope, at: Vector2)
            local cell = cellpool:Borrow()
            local size = peek(props.CellSize)
            cell.Position = UDim2.fromOffset(at.X * size, at.Y * size)
            
            -- Return to pool on cleanup
            table.insert(scope, function()
                cell.Parent = script
                cellpool:Return(cell)
            end)

            return cell
        end)
    }
end