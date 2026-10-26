-- Formats files on save using the `conform` plugin

-- Presence of this file disables format on save (persists across sessions)
local disabled_flag = vim.fn.stdpath("state") .. "/format_on_save_disabled"

local function format_on_save_enabled()
	return vim.fn.filereadable(disabled_flag) == 0
end

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
		format_on_save = function()
			if not format_on_save_enabled() then
				return
			end
			return { lsp_fallback = true, timeout_ms = 2500 }
		end,
	},
	config = function(_, opts)
		local conform = require("conform")

		conform.setup(opts)

		SET_MAP({ "n", "v" }, "<leader>ff", function()
			conform.format({ lsp_fallback = true, async = false, timeout_ms = 5000 })
		end, "Format File")

		SET_MAP("n", "<leader>ft", function()
			if format_on_save_enabled() then
				vim.fn.writefile({}, disabled_flag)
				vim.notify("Format on save disabled")
			else
				vim.fn.delete(disabled_flag)
				vim.notify("Format on save enabled")
			end
		end, "Toggle Format on Save")
	end,
}
