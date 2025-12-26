local process = require "@lune/process"
local run = require "./util/run"
local watcher = require "./util/watcher"

-- Watch mode
local watch = false
for _, arg in process.args do
    if arg == "-w" or arg == "--watch" then
        watch = true
        break
    end
end

local function compile()
    --1. Create src sourcemap
    run("rojo", { "sourcemap", ".", "-o", "sourcemap.json" })

    --2. Process through Darklua
    run("darklua", { "process", "src", "build" }) 

    --3. Generate build sourcemap (Darklua output)
    run("rojo", { "sourcemap", "build.project.json", "-o", "build.sourcemap.json" })

    --4. Build final output
    run("rojo", { "build", "build.project.json", "-p", "conway.rbxm" })
end

compile()

if watch then
    watcher({
        filePatterns = {
            "src/.*%.luau",
            "./*.project.json"
        },
        onAdded = compile,
        onRemoved = compile,
        onChanged = compile,
    })
end

process.exit(0)