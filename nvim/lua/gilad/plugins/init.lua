-- Short no config libs
return {
	"nvim-lua/plenary.nvim",
	"folke/zen-mode.nvim",
	"christoomey/vim-tmux-navigator", -- tmux & split window nav
	-- { "https://github.com/fresh2dev/zellij.vim", lazy = false },
	{ "norcalli/nvim-colorizer.lua", config = true }, -- color highlighter
	{ "folke/todo-comments.nvim", config = true },
	{ "chentoast/marks.nvim", event = "VeryLazy" },
}
