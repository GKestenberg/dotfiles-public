-- Formats files on save using the `conform` plugin

return {
	"stevearc/conform.nvim",
	event = { "BufReadPre", "BufNewFile" },
	opts = {
		formatters_by_ft = {
			css = { "prettier" },
			go = {
				"gofumpt",
				-- "golines",
				-- "goimports-reviser",
			},
			graphql = { "prettier" },
			html = { "prettier" },
			javascript = { "prettier" },
			javascriptreact = { "prettier" },
			json = { "prettier" },
			lua = { "stylua" },
			python = { "isort", "black" },
			rust = { "rustfmt" },
			svelte = { "prettier" },
			typescript = { "prettier" },
			typescriptreact = { "prettier" },
			yaml = { "prettier" },
		},
		formatters = {
			-- 	golines = { args = { "--max-len=120" } },
		},
		lang_to_ext = {
			bash = "sh",
		},
		format_on_save = {
			lsp_fallback = true,
			timeout_ms = 2500,
		},
	},
	config = function(_, opts)
		local conform = require("conform")

		conform.setup(opts)

		SET_MAP({ "n", "v" }, "<leader>f", function()
			conform.format({ lsp_fallback = true, async = false, timeout_ms = 5000 })
		end, "Format File")
	end,
}
