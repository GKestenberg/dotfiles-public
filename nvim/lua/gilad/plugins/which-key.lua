return {
	"folke/which-key.nvim",
	event = "VeryLazy",
	dependencies = {
		"echasnovski/mini.nvim",
	},
	init = function()
		vim.o.timeout = true
		vim.o.timeoutlen = 500
	end,
	keys = {
		{
			"<leader>?",
			function()
				require("which-key").show({ global = true })
			end,
			desc = "Show Keymaps (which-key)",
			mode = { "n", "v" },
		},
	},
	opts = {
		spec = {
			{
				mode = "n",
				{ "<leader>a", desc = "[A]vente Actions" },
				{ "<leader>c", desc = "[C]ode Actions" },
				{ "<leader>l", desc = "[L]SP Actions" },
				{ "<leader>g", desc = "[G]it Actions" },
				{ "<leader>n", desc = "[N]otification Actions" },
				{ "<leader>m", desc = "[M]d Actions" },
				{ "<leader>p", desc = "[P]review Actions" },
				{ "<leader>b", desc = "[B]uffer Actions" },
				{ "<leader>t", desc = "Open [T]erminal" },
				{ "ZZ", desc = "Quit (Save)" },
				{ "ZQ", desc = "Quit (Force)" },
			},
		},
	},
	config = true,
}
