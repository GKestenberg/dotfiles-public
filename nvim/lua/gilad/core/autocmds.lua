local function augroup(name)
	return vim.api.nvim_create_augroup("lazyvim_" .. name, { clear = true })
end

-- close some filetypes with <q>
vim.api.nvim_create_autocmd("FileType", {
	group = augroup("close_with_q"),
	pattern = {
		"PlenaryTestPopup",
		"help",
		"lspinfo",
		"man",
		"notify",
		"qf",
		"query",
		"spectre_panel",
		"startuptime",
		"tsplayground",
		"neotest-output",
		"checkhealth",
		"neotest-summary",
		"neotest-output-panel",
	},
	callback = function(event)
		vim.bo[event.buf].buflisted = false
		vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = event.buf, silent = true })
	end,
})

-- Fix conceallevel for json files
vim.api.nvim_create_autocmd("FileType", {
	group = augroup("json_conceal"),
	pattern = { "json", "jsonc", "json5" },
	callback = function()
		vim.opt_local.conceallevel = 0
	end,
})

-- Custom md syntax
vim.api.nvim_create_autocmd("FileType", {
	pattern = { "gitcommit", "markdown" },
	callback = function()
		vim.opt_local.spell = true
		vim.opt_local.foldmethod = "indent"
		-- -- Some markdown files are not highlighted correctly
		-- vim.cmd("TSToggle highlight")
	end,
})

vim.filetype.add({ extension = { ejs = "html", mdx = "markdown", conf = "ini" } })

---@param num number|nil
local function setTabWidth(num)
	if num == nil then
		return
	end
	vim.opt_local.tabstop = num
	vim.opt_local.shiftwidth = num
	vim.opt_local.expandtab = true
end

vim.api.nvim_create_autocmd("FileType", {
	pattern = { "dart", "sql" },
	callback = function()
		setTabWidth(4)
	end,
})

vim.api.nvim_create_autocmd("FileType", {
	pattern = { "json", "cpp", "html", "ejs", "nix" },
	callback = function()
		setTabWidth(2)
	end,
})

---@param path string
---@return string|nil
local function find_prettierrc(path)
	-- Prevent infinite recursion with depth limit
	local max_depth = 10
	local visited = {}

	local function search_recursive(current_path, depth)
		-- Safety checks
		if depth > max_depth then
			return nil
		end

		-- Normalize path to prevent duplicate visits
		local normalized_path = vim.fn.resolve(current_path)
		if visited[normalized_path] then
			return nil
		end
		visited[normalized_path] = true

		-- Check if directory exists and is readable
		if vim.fn.isdirectory(current_path) ~= 1 then
			return nil
		end

		-- Use more efficient single search with multiple patterns
		local patterns = { ".prettierrc", ".prettierrc.json", ".prettierrc.js", ".prettierrc.yml", ".prettierrc.yaml" }

		for _, pattern in ipairs(patterns) do
			local found = vim.fn.findfile(pattern, current_path)
			if found ~= "" then
				return found
			end
		end

		-- Check specific child directories (non-recursively first)
		local child_dirs = { "frontend", "client", "web", "ui" }
		for _, dir in ipairs(child_dirs) do
			local child_path = current_path .. "/" .. dir
			if vim.fn.isdirectory(child_path) == 1 then
				for _, pattern in ipairs(patterns) do
					local found = vim.fn.findfile(pattern, child_path)
					if found ~= "" then
						return found
					end
				end
			end
		end

		-- Traverse up to parent directory
		local parent = vim.fn.fnamemodify(current_path, ":h")

		-- Stop at root or if parent is same as current (shouldn't happen, but safety)
		if parent == current_path or parent == "/" or parent == "" then
			return nil
		end

		-- Continue searching up
		return search_recursive(parent, depth + 1)
	end

	return search_recursive(path, 0)
end

---@param path string
---@return string|nil
local function read_prettierrc(path)
	if vim.fn.filereadable(path) == 1 then
		local lines = vim.fn.readfile(path)
		local prettierrc_content = table.concat(lines, "\n")
		return prettierrc_content
	else
		vim.notify("[INTERNAL] .prettierrc file not found specified directory")
	end
	return nil
end

---@param printWidth string
local function setPrettierPrintWidth(printWidth)
	if printWidth == nil then
		return
	end
	vim.opt_local.colorcolumn = printWidth
end

vim.api.nvim_create_autocmd("FileType", {
	pattern = { "javascript", "javascriptreact", "typescript", "typescriptreact" },
	callback = function()
		setTabWidth(2)
		local filepath = vim.fn.expand("%:p:h")
		local prettierrc_path = find_prettierrc(filepath)
		if prettierrc_path == nil then
			vim.notify("[AUTOCMD] .prettierrc file not found")
			return
		end
		local content = read_prettierrc(prettierrc_path)
		if content == nil then
			return
		end
		local tabWidth = tonumber(content:match('"tabWidth"%s*:%s*(%d+)'))
		setTabWidth(tabWidth)
		setPrettierPrintWidth(content:match('"printWidth"%s*:%s*(%d+)'))
	end,
})

vim.api.nvim_create_autocmd("FileType", {
	pattern = "yml",
	callback = function()
		vim.opt_local.foldmethod = "indent"
	end,
})

vim.filetype.add({
	filename = {
		["Tiltfile"] = "starlark",
	},
	extension = {
		tilt = "starlark",
	},
	pattern = {
		[".*Tiltfile.*"] = "starlark",
	},
})

-- vim.api.nvim_create_autocmd("FileType", {
-- 	pattern = "kotlin",
-- 	callback = function()
-- 		local client = vim.lsp.start_client({
-- 			name = "kotlin-lsp",
-- 			cmd = { "/Users/giladkestenberg/code/projects/kotlin_lsp/kt-lsp" },
-- 			root_dir = vim.loop.cwd(),
-- 		})
--
-- 		if not client then
-- 			vim.notify("kotlin-lsp: error: problem starting client")
-- 			return
-- 		end
--
-- 		vim.lsp.buf_attach_client(0, client)
-- 	end,
-- })
