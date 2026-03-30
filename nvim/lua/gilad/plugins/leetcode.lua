local leet_arg = "leetcode.nvim"

return {
	"kawre/leetcode.nvim",
	lazy = leet_arg ~= vim.fn.argv()[1],
	cmd = "Leet",
	build = ":TSUpdate html",
	dependencies = {
		"MunifTanjim/nui.nvim",

		"nvim-treesitter/nvim-treesitter",
		"nvim-tree/nvim-web-devicons",
	},
	opts = {
		lang = "typescript",
	},
	config = function(_, opts)
		require("leetcode").setup(opts)

        -- stylua: ignore start
		SET_MAP("n", "<leader>lt", ":Leet test<CR>",   "[L]eet [T]est")
		SET_MAP("n", "<leader>ls", ":Leet submit<CR>", "[L]eet [S]ubmit")
		SET_MAP("n", "<leader>ld", ":Leet desc<CR>",   "[L]eet [D]escription")
		SET_MAP("n", "<leader>lg", ":Leet lang<CR>",   "[L]eet Lan[G]uage")
		-- stylua: ignore end
	end,
}
