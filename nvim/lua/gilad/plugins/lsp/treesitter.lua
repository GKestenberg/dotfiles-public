-- nvim-treesitter `main` branch: no `ensure_installed`/`highlight` opts anymore.
-- Parsers are installed via the API and highlighting is started by the
-- FileType autocmd in core/autocmds.lua.
local parsers = {
	"go",
	"gomod",
	"gosum",
	"gotmpl",
	"gowork",
	"rust",
	"python",
	"javascript",
	"typescript",
	"tsx",
	"lua",
	"bash",
	"json",
	"yaml",
	"toml",
	"html",
	"css",
	"markdown",
	"markdown_inline",
}

return {
	"nvim-treesitter/nvim-treesitter",
	branch = "main",
	lazy = false,
	build = ":TSUpdate",
	config = function()
		require("nvim-treesitter").setup()

		local installed = require("nvim-treesitter.config").get_installed("parsers")
		local missing = vim.tbl_filter(function(lang)
			return not vim.tbl_contains(installed, lang)
		end, parsers)

		if #missing > 0 then
			require("nvim-treesitter").install(missing)
		end
	end,
}
