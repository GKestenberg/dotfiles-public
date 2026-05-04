return {
	"nvim-treesitter/nvim-treesitter",
	build = ":TSUpdate",
	opts = {
		ensure_installed = {
			"go",
			"python",
			"javascript",
			"typescript",
			"lua",
			"bash",
			"json",
			"yaml",
			"html",
			"css",
			"markdown",
		},
		auto_install = true,
		highlight = { enable = true },
	},
}
