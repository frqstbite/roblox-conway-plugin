--!strict
local RunService = game:GetService("RunService")
if not RunService:IsEdit() then
    return
end

local Studio = settings().Studio

local CELL_SIZE = 12
local FPS = 10
local ID = "conway"
local NAME = "Conway's Plugin of Life"
local SIZE_DEFAULT = Vector2.new(600, 400)
local SIZE_MINIMUM = Vector2.new(300, 400)

local Fusion = require "@pkg/Fusion"
local OnEvent = Fusion.OnEvent
local Out = Fusion.Out

local Simulation = require "@conway/Components/Simulation"
local Theme = require "@conway/Theme"

local scope = Fusion.scoped(Fusion)
local canvas = scope:Value(SIZE_DEFAULT)
local theme = scope:Value(Studio.Theme)
table.insert(scope, Studio.ThemeChanged:Connect(function()
    theme:set(Studio.Theme)
end))

-- Create widget
local widget = scope:Hydrate(plugin:CreateDockWidgetPluginGui(ID, DockWidgetPluginGuiInfo.new(
    Enum.InitialDockState.Float,
    false,
    false,
    SIZE_DEFAULT.X,
    SIZE_DEFAULT.Y,
    SIZE_MINIMUM.X,
    SIZE_MINIMUM.Y
))) {
    [Out "AbsoluteSize"] = canvas,
    Name = ID,
    Title = NAME,
} :: DockWidgetPluginGui

-- Create simulation inside widget
Theme:is(theme):during(Simulation, scope, {
    CanvasSize = canvas,
    CellSize = CELL_SIZE,
    Parent = widget,
})

-- Create ribbon
local toolbar = plugin:CreateToolbar(NAME)
local button
button = scope:Hydrate(toolbar:CreateButton(NAME, "Toggle the Conway widget", "rbxassetid://87371430812024")) {
    ClickableWhenViewportHidden = true,
    [OnEvent "Click"] = function()
        -- Toggle widget visibility on button click
        widget.Enabled = not widget.Enabled
        button:SetActive(widget.Enabled)
    end,
} :: PluginToolbarButton
button:SetActive(widget.Enabled)

-- Clean up on plugin unload
table.insert(scope, plugin.Unloading:Connect(function()
    scope:doCleanup()
end))