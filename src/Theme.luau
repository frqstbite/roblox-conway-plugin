local Studio = settings().Studio

local Fusion = require "@pkg/Fusion"
type Contextual<T> = Fusion.Contextual<T>
type Scope = Fusion.Scope<typeof(Fusion)>
type UsedAs<T> = Fusion.UsedAs<T>

return Fusion.Contextual(Studio.Theme) :: Contextual<UsedAs<StudioTheme>>