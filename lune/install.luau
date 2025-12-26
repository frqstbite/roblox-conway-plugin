local process = require "@lune/process"
local run = require "./util/run"

run("wally", { "install" })
run("rojo", { "sourcemap", ".", "-o", "sourcemap.json" })
run("wally-package-types", { "Packages", "--sourcemap", "sourcemap.json" })

process.exit(0)