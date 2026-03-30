return {
	-- Creates a mapping to render markdown files in browser
	"iamcco/markdown-preview.nvim",
	cmd = { "MarkdownPreview", "MarkdownPreviewStop" },
	lazy = true,
	ft = "markdown",
	build = function()
		vim.fn["mkdp#util#install"]()
	end,
	init = function()
		vim.g.mkdp_theme = "dark"
		SET_MAP("n", "<leader>mp", "<cmd>MarkdownPreview<cr>", "[M]d [P]review")
	end,
}
