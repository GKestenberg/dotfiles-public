-- Highlights markdown files and provides some useful mappings for
-- editing/navigating through them.

local MD_ROOT_PATH = "~/Files/"

local function get_daily_notes_folder()
	local date = os.date("*t")
	local year = date.year % 100
	local month = string.format("%02d", date.month)
	return string.format("private/journal/%d/%s", year, month)
end

-- Open the URL in the default web browser.
---@param url string
local function follow_url(url)
	vim.fn.jobstart({ "open", url })
end

-- Optional, alternatively you can customize the frontmatter data.
---@return table
local function get_note_frontmatter(note)
	if note.title then
		note:add_alias(note.title)
	end

	local id = note.id
	if not string.match(note.id, "%d%d%d%d%d%d%d%d%d%d%-") then
		id = tostring(os.time()) .. "-" .. note.id
	end
	local out = { id = id, aliases = note.aliases, tags = note.tags }

	if note.metadata ~= nil and not vim.tbl_isempty(note.metadata) then
		for k, v in pairs(note.metadata) do
			out[k] = v
		end
	end

	return out
end

SET_MAP("n", "<leader>mt", function()
	require("lazy").load({ plugins = { "obsidian.nvim" } })
	vim.cmd("ObsidianToday")
end, "[M]d [T]oday")
SET_MAP("n", "<leader>my", function()
	require("lazy").load({ plugins = { "obsidian.nvim" } })
	vim.cmd("ObsidianToday -1")
end, "[M]d [Y]esterday")
SET_MAP("n", "<leader>mT", function()
	require("lazy").load({ plugins = { "obsidian.nvim" } })
	vim.cmd("ObsidianQuickSwitch todo")
end, "[M]d [T]odo")
SET_MAP("n", "<leader>mo", function()
	require("lazy").load({ plugins = { "obsidian.nvim" } })
	vim.cmd("ObsidianOpen")
end, "[M]d [O]pen")

return {
	"epwalsh/obsidian.nvim",
	lazy = true,
	ft = "markdown",
	dependencies = {
		"nvim-lua/plenary.nvim",
		"nvim-treesitter/nvim-treesitter",
	},
	opts = {
		ui = { enable = false },
		workspaces = { { name = "personal", path = MD_ROOT_PATH } },
		daily_notes = { folder = get_daily_notes_folder() },
		completion = {
			nvim_cmp = true,
			min_chars = 2,
		},
		new_notes_location = "journal",

		follow_url_func = follow_url,
		note_frontmatter_func = get_note_frontmatter,
	},
}
