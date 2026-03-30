return {
	"lervag/vimtex",
	lazy = false,
	init = function()
		vim.g.vimtex_view_method = "sioyek"
		vim.g.vimtex_compiler_latexmk = {
			aux_dir = "dist",
			out_dir = "pdf",
			options = {},
		}
	end,
}
