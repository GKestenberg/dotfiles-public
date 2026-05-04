return {
	url = "https://codeberg.org/andyg/leap.nvim",
	lazy = false,
	dependencies = { "tpope/vim-repeat" },
	config = function()
		vim.keymap.set({ "n", "x", "o" }, "s", "<Plug>(leap-forward)")
		vim.keymap.set({ "n", "x", "o" }, "S", "<Plug>(leap-backward)")
	end,
}
