return {
	{
		"stevearc/oil.nvim",
		---@module 'oil'
		---@type oil.SetupOpts
		opts = {
			view_options = {
				show_hidden = false,
				is_hidden_file = function(name, _bufnr)
					return name == "__pycache__"
				end,
			},
		},
		dependencies = { { "echasnovski/mini.icons", opts = {} } },
		config = function(_, opts)
			require("oil").setup(opts)
			SET_MAP("n", "<leader>o", ":Oil<CR>", "Open Oil")
		end,
		lazy = false,
	},
	{

		"nvim-neo-tree/neo-tree.nvim",
		branch = "v3.x",
		dependencies = {
			{ "antosha417/nvim-lsp-file-operations", config = true },
			"nvim-lua/plenary.nvim",
			"nvim-tree/nvim-web-devicons",
			"MunifTanjim/nui.nvim",
			{
				"adelarsq/image_preview.nvim",
				event = "VeryLazy",
				config = function()
					require("image_preview").setup()
				end,
			},
		},
		cmd = "Neotree",
		deactivate = function()
			vim.cmd([[Neotree close]])
		end,
		opts = {
			sources = { "filesystem", "buffers", "git_status", "document_symbols" },
			open_files_do_not_replace_types = { "terminal", "Trouble", "trouble", "qf", "Outline" },
			filesystem = {
				filtered_items = {
					hide_by_name = { ".DS_Store" },
					always_show_by_pattern = { ".env*" },
				},
				bind_to_cwd = false,
				follow_current_file = { enabled = true },
				use_libuv_file_watcher = true,
				group_empty_dirs = true,
			},
			window = {
				mappings = {
					["<space>"] = "none",
					["Y"] = function(state)
						local node = state.tree:get_node()
						local path = node:get_id()
						vim.fn.setreg("+", path, "c")
					end,
					["<leader>p"] = "image_wezterm",
				},
			},
			default_component_configs = {
				indent = {
					with_expanders = true,
					expander_collapsed = "",
					expander_expanded = "",
					expander_highlight = "NeoTreeExpander",
				},
			},
			commands = {
				image_wezterm = function(state)
					local node = state.tree:get_node()
					if node.type == "file" then
						require("image_preview").PreviewImage(node.path)
					end
				end,
			},
		},
		config = function(_, opts)
			require("neo-tree").setup(opts)

			vim.api.nvim_create_autocmd("TermClose", {
				pattern = "*lazygit",
				callback = function()
					if package.loaded["neo-tree.sources.git_status"] then
						require("neo-tree.sources.git_status").refresh()
					end
				end,
			})
		end,
	},
}
