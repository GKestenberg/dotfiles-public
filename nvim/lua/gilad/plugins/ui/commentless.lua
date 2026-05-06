return {
	"soemre/commentless.nvim",
	cmd = "Commentless",
	lazy = true,
	keys = {
		{
			"<leader>/",
			function()
				require("commentless").toggle()
			end,
			desc = "Toggle Comments",
		},
	},
	dependencies = {
		"nvim-treesitter/nvim-treesitter",
	},
	opts = {
		-- Customize Configuration
	},
}
