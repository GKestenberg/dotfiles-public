return {
	{
		-- Installs all the LSP/Format servers
		"williamboman/mason.nvim",
		event = "VeryLazy",
		opts = {
			ensure_installed = {
				"gopls",
				"tilt",
			},
			ui = {
				icons = {
					package_installed = "✓",
					package_pending = "➜",
					package_uninstalled = "✗",
				},
			},
		},
	},
	{
		-- For Conform.nvim to do formatting
		"WhoIsSethDaniel/mason-tool-installer.nvim",
		event = "VeryLazy",
		dependencies = {
			"williamboman/mason.nvim",
		},
		opts = {
			ensure_installed = {
				"black",
				"eslint_d",
				"isort",
				"prettier",
				"pyright",
				"stylua",
				-- Frontend
				"tailwindcss-language-server",
				"css-lsp",
				"emmet-ls",
				-- "shellharden",
				"stylua",
				-- "terraformls",
				"ktlint",
				-- "rust_analyzer",
				"latexindent",
				"clangd",
				-- Go
				"gopls",
				"gofumpt",
				"goimports",
				"goimports-reviser",
				"golines",
			},
			auto_update = true,
			run_on_start = true,
			start_delay = 3000,
		},
		config = function(_, opts)
			require("mason-tool-installer").setup(opts)
		end,
	},
}
