--!strict
local Fusion = require "@pkg/Fusion"
type Computed<T> = Fusion.Computed<T>
type Scope = Fusion.Scope<typeof(Fusion)>
type Spring<T> = Fusion.Spring<T>
type UsedAs<T> = Fusion.UsedAs<T>

local theme = require "@conway/Theme"

return function(scope: Scope, color: UsedAs<Enum.StudioStyleGuideColor>, modifier: UsedAs<Enum.StudioStyleGuideModifier>?): Spring<Color3>
    local state = theme:now()
    return scope:Spring(scope:Computed(function(use)
        return use(state):GetColor(use(color), use(modifier or Enum.StudioStyleGuideModifier.Default))
    end), 10, 0.9)
end