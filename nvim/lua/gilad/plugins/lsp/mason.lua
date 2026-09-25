return {
	{
		-- Installs all the LSP/Format servers
		"williamboman/mason.nvim",
		event = "VeryLazy",
		opts = {
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
		-- Installs everything enabled in core/lsp.lua, plus Conform.nvim's formatters.
		-- Keep in sync with the `servers` list there; names here are mason package
		-- names, which differ from lspconfig server names (rust-analyzer, not rust_analyzer).
		"WhoIsSethDaniel/mason-tool-installer.nvim",
		event = "VeryLazy",
		dependencies = {
			"williamboman/mason.nvim",
		},
		opts = {
			ensure_installed = {
				-- Formatters / linters
				"black",
				"eslint_d",
				"isort",
				"prettier",
				"stylua",
				"ktlint",
				"latexindent",
				-- "shellharden",
				-- Frontend
				"tailwindcss-language-server",
				"css-lsp",
				"emmet-ls",
				"html-lsp",
				"svelte-language-server",
				"graphql-language-service-cli",
				"prisma-language-server",
				-- Go
				"gopls",
				"gofumpt",
				"goimports",
				"goimports-reviser",
				"golines",
				-- Rust: rust-analyzer comes from rustup so its ABI matches the
				-- toolchain; a mason copy would shadow it via the PATH prepend in
				-- core/lsp.lua and break proc-macro expansion.
				-- Python
				"pyright",
				-- Lua
				"lua-language-server",
				-- Systems / infra
				"clangd",
				"bash-language-server",
				"terraform-ls",
				"nil",
				"tilt",
				-- Haskell
				"haskell-language-server",
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
