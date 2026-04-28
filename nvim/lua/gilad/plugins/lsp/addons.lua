-- Extensions built on top of the LSP

local ftMap = {
	vim = "indent",
	python = "indent",
	git = "",
}

return {
	{
		-- Keeps relevant context visible when scrolling through the buffer
		"nvim-treesitter/nvim-treesitter-context",
		dependencies = { "nvim-treesitter/nvim-treesitter" },
		config = function()
			require("treesitter-context").setup()
		end,
	},
	{
		-- Detects PEP 723 inline script deps and points pyright at the uv venv
		"linux-cultist/venv-selector.nvim",
		dependencies = { "neovim/nvim-lspconfig" },
		ft = "python",
		opts = {},
	},
	{
		-- Automatically generates folds
		"kevinhwang91/nvim-ufo",
		dependencies = { "kevinhwang91/promise-async", "neovim/nvim-lspconfig" },
		opts = {
			provider_selector = function(bufnr, filetype, buftype)
				return ftMap[filetype]
			end,
		},
		config = function(_, opts)
			require("ufo").setup(opts)
		end,
	},
}
