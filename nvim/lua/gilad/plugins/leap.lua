return {
	"ggandor/leap.nvim",
	lazy = false,
	dependencies = { "tpope/vim-repeat" },
	config = function()
		require("leap").set_default_keymaps()
	end,
}
