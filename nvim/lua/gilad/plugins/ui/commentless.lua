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
	opts = {
		-- Customize Configuration
	},
}
