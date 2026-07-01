SET_MAP("n", "K", vim.lsp.buf.hover, "Show Documentation")
SET_MAP("n", "gi", vim.lsp.buf.implementation, "Go to Implementation")

local signs = { ERROR = " ", WARN = " ", HINT = "󰠠 ", INFO = " " }
vim.diagnostic.config({ signs = { text = signs } })
vim.env.PATH = table.concat({ vim.fn.stdpath("data"), "mason", "bin" }, "/") .. ":" .. vim.env.PATH

vim.lsp.config["lua_ls"] = {
	settings = {
		Lua = {
			runtime = { version = "LuaJIT" },
			workspace = {
				ceckThirdParty = false,
				library = {
					vim.env.VIMRUNTIME,
					vim.fn.expand("~/.local/share/nvim/lazy/"),
				},
			},
		},
	},
}
vim.lsp.config["emmet_ls"] = {
	filetypes = { "html", "typescriptreact", "javascriptreact", "css", "sass", "scss", "less", "svelte" },
}
vim.lsp.config["tailwindcss"] = {
	filetypes = { "html", "svelte", "javascriptreact", "typescriptreact" },
}
vim.lsp.config["graphql"] = {
	filetypes = { "graphql", "gql", "svelte", "typescriptreact", "javascriptreact" },
}
vim.lsp.config["svelte"] = {
	root_markers = { "package.json", ".git" },
	on_attach = function(client)
		-- Keep js & svelte files in sync
		vim.api.nvim_create_autocmd("BufWritePost", {
			pattern = { "*.js", "*.ts" },
			callback = function(ctx)
				if client.name == "svelte" then
					client:notify("$/onDidChangeTsOrJsFile", { uri = ctx.file })
				end
			end,
		})
	end,
}

vim.lsp.config["gopls"] = {
	position_encoding = "utf-8",
	settings = {
		gopls = {
			directoryFilters = {
				"-**/node_modules",
				"-**/testdata", -- drop if you navigate into test fixtures
				"-dashboard", -- non-Go frontend; adjust to your tree
				"-bin",
				"-dist",
			},
			staticcheck = false, -- see below
			analyses = { unusedparams = true },
			completionBudget = "100ms", -- time-box completion keystrokes
			usePlaceholders = false,
			semanticTokens = false,
		},
	},
}

vim.lsp.config["tilt_ls"] = {
	filetypes = { "starlark" },
}

local servers = {
	"emmet_ls",
	"tailwindcss",
	"graphql",
	"svelte",
	"gopls",
	"cssls",
	"hls",
	"html",
	"prismals",
	"terraformls",
	"clangd",
	"nil_ls",
	"pyright",
	"bashls",
	"tilt_ls",
	"lua_ls",
}

vim.lsp.enable(servers)
