return {
	"echasnovski/mini.nvim",
	version = false,
	dependencies = { "JoosepAlviste/nvim-ts-context-commentstring" },
	config = function()
		require("mini.icons").setup()
		require("mini.ai").setup()
		require("mini.align").setup()
		require("mini.comment").setup({
			options = {
				custom_commentstring = function()
					return require("ts_context_commentstring").calculate_commentstring() or vim.bo.commentstring
				end,
			},
		})
		-- require("mini.pairs").setup()
	end,
}
