return {
	"joom/latex-unicoder.vim",
	lazy = true,
	ft = "markdown",
	config = function()
		vim.api.nvim_del_keymap("n", "<C-l>")
		vim.api.nvim_del_keymap("i", "<C-l>")
		vim.api.nvim_del_keymap("v", "<C-l>")

		SET_MAP({ "n", "i", "v" }, "<C-l>", ":wincmd l<CR>", "Move Right")
		SET_MAP("v", "<leader>cm", ":'<,'>call unicoder#selection()<cr>", "Convert Latex")
	end,
}
