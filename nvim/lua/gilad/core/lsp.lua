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

-- sqls: without a connection it only knows keywords and logs
-- "no database connection" on every request. It picks the DSN up from
-- $DATABASE_URL / $DB_URL, else from DATABASE_URL= / DB_URL= in <root>/.env.
-- Only postgres:// URLs are wired; anything else (e.g. pass://) is ignored.
-- A project can also ship its own sqls config.yml at the root instead.
vim.lsp.config["sqls"] = {
	root_markers = { { "config.yml" }, { ".env", ".git" } },
	before_init = function(_, config)
		local dsn = vim.env.DATABASE_URL or vim.env.DB_URL
		if not dsn and config.root_dir then
			local f = io.open(config.root_dir .. "/.env")
			if f then
				for line in f:lines() do
					line = line:gsub("^%s*export%s+", "")
					local k, v = line:match("^%s*([%w_]+)%s*=%s*(.-)%s*$")
					if (k == "DATABASE_URL" or k == "DB_URL") and v and v ~= "" then
						dsn = v:gsub('^"(.*)"$', "%1"):gsub("^'(.*)'$", "%1")
						break
					end
				end
				f:close()
			end
		end
		if dsn and dsn:match("^postgres") then
			config.settings = vim.tbl_deep_extend("force", config.settings or {}, {
				sqls = { connections = { { driver = "postgresql", dataSourceName = dsn } } },
			})
		end
	end,
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
	"sqls",
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
