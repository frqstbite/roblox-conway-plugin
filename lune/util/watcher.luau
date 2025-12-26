local fs = require "@lune/fs"
local stdio = require "@lune/stdio"
local task = require "@lune/task"

local xor = require "./xor"

type FileChanges = { string }
type Options = {
	filePatterns: { string },
	onAdded: ((changedFiles: FileChanges) -> ())?,
	onRemoved: ((changedFiles: FileChanges) -> ())?,
	onChanged: ((changedFiles: FileChanges) -> ())?,
}

local function maybeCall<T>(callback: ((...T) -> ())?, ...)
	if callback then
		pcall(callback, ...)
	end
end

local function getWatchedFiles(filePatterns: { string }): { string }
	local files = {}

	local function traverse(rootDir: string, filePattern: string)
		for _, file in fs.readDir(rootDir) do
			local filePath = `{rootDir}/{file}`
			if fs.isDir(filePath) then
				traverse(filePath, filePattern)
			else
				if filePath:match(filePattern) then
					table.insert(files, filePath)
				end
			end
		end
	end

	for _, filePattern in filePatterns do
		local rootDir = filePattern:split("/")[1]

		assert(
			rootDir and fs.isDir(rootDir),
			`first part of file pattern must be a directory ({rootDir} is not a directory)`
		)

		traverse(rootDir, filePattern)
	end

	return files
end

local function watcher(options: Options)
	local prevWatchedFileMetadata: { [string]: fs.Metadata } = {}
	local watchedFiles = getWatchedFiles(options.filePatterns)
	local prevWatchedFiles

	print("watching files:")
	stdio.write(stdio.style("dim"))
	for _, watchedFile in watchedFiles do
		print(`> {watchedFile}`)
	end
	stdio.write(stdio.style("reset"))
	print("listening for file changes...")

	-- FIXME: Ctrl+C doesn't cancel the loop. Is this a Lune bug or a Foreman bug?
	while true do
		local changedFiles: FileChanges = {}

		if prevWatchedFiles and #watchedFiles ~= #prevWatchedFiles then
			changedFiles = xor(prevWatchedFiles, watchedFiles)

			if #watchedFiles > #prevWatchedFiles then
				maybeCall(options.onAdded, changedFiles)
			elseif #watchedFiles < #prevWatchedFiles then
				maybeCall(options.onRemoved, changedFiles)

				for _, filePath in changedFiles do
					prevWatchedFileMetadata[filePath] = nil
				end
			end
		end

		for _, watchedFile in watchedFiles do
			local metadata = fs.metadata(watchedFile)

			local prevMetadata = prevWatchedFileMetadata[watchedFile]
			if prevMetadata and metadata.modifiedAt > prevMetadata.modifiedAt then
				table.insert(changedFiles, watchedFile)
			end

			prevWatchedFileMetadata[watchedFile] = metadata
		end

		if #changedFiles > 0 then
			maybeCall(options.onChanged, changedFiles)
		end

		prevWatchedFiles = watchedFiles
		task.wait(1)
		watchedFiles = getWatchedFiles(options.filePatterns)
	end
end

return watcher