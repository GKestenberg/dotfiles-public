return {
	{
		"pmizio/typescript-tools.nvim",
		lazy = true,
		ft = { "javascript", "typescript", "svelte", "javascriptreact", "typescriptreact" },
		dependencies = { "nvim-lua/plenary.nvim", "neovim/nvim-lspconfig" },
		opts = {},
	},
	{
		"akinsho/flutter-tools.nvim",
		ft = "dart",
		dependencies = { "nvim-lua/plenary.nvim", "nvim-telescope/telescope.nvim" },
		opts = {
			widget_guides = {
				enabled = true,
			},
			lsp = {
				color = {
					enabled = true,
					background = true,
					background_color = { r = 19, g = 17, b = 24 },
				},
			},
		},
		config = function()
			require("flutter-tools").setup()
			local telescope = require("telescope")

			local flutter_commands = telescope.extensions.flutter.commands
			SET_MAP("n", "<leader>cf", flutter_commands, "[C]ommands in [F]lutter")
		end,
	},
	{
		"mrcjkb/rustaceanvim",
		version = "^5",
		lazy = true,
		ft = "rust",
		["rust-analyzer"] = {
			cargo = { allFeatures = true },
			imports = { group = { enable = true } },
			completion = { postfix = { enable = true } },
			rustfmt = {},
			overrideCommand = { "leptosfmt", "--stdin", "--rustfmt" },
		},
	},
	{
		"scalameta/nvim-metals",
		dependencies = { "nvim-lua/plenary.nvim" },
		ft = { "scala", "sbt", "java" },
		opts = function()
			return require("metals").bare_config()
		end,
		config = function(self, metals_config)
			local nvim_metals_group = vim.api.nvim_create_augroup("nvim-metals", { clear = true })
			vim.api.nvim_create_autocmd("FileType", {
				pattern = self.ft,
				callback = function()
					require("metals").initialize_or_attach(metals_config)
				end,
				group = nvim_metals_group,
			})
		end,
	},
}
