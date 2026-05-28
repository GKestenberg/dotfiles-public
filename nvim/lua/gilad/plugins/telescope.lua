return {
	"nvim-telescope/telescope.nvim",
	branch = "master",
	event = "VeryLazy",
	dependencies = {
		"nvim-lua/plenary.nvim",
		"nvim-tree/nvim-web-devicons",
		{ "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
	},
	opts = {

		defaults = {
			path_display = { "truncate " },
			pickers = { find_files = { hidden = true, no_ignore = true } },
			layout_strategy = "vertical",
			layout_config = { height = 0.95, width = 0.95 },
		},
		pickers = {
			find_files = { hidden = true },
			lsp_definitions = {
				file_ignore_patterns = { "%.d%.ts$" },
				show_line = false,
			},
			lsp_type_definitions = {
				file_ignore_patterns = {},
			},
		},
	},
	config = function(_, opts)
		-- Check and create .rgignore if it doesn't exist
		-- This is a workaround so that .env files are included in search
		-- https://github.com/LunarVim/LunarVim/discussions/3770
		local home = os.getenv("HOME")
		local rgignore_path = home .. "/.rgignore"
		local rgignore_file = io.open(rgignore_path, "r")

		if not rgignore_file then
			rgignore_file = io.open(rgignore_path, "w")
			if rgignore_file then
				rgignore_file:write("!.env*\n")
				rgignore_file:close()
			end
		else
			rgignore_file:close()
		end

		local telescope = require("telescope")
		local builtin = require("telescope.builtin")

		telescope.setup(opts)
		telescope.load_extension("fzf")

        -- stylua: ignore start
        SET_MAP("n",  "gd",    builtin.lsp_definitions,      "[G]o To [D]efinition")
        SET_MAP("n",  "gr",    builtin.lsp_references,       "[G]o To [R]eferences")
        SET_MAP("n",  "gi",    builtin.lsp_implementations,  "[G]o To [I]mplementations")
        SET_MAP("n",  "gt",    builtin.lsp_type_definitions, "[G]o To [T]ype definitions")

        SET_MAP("n",  ";d",    builtin.diagnostics,          "Search [D]iagnostics")
        SET_MAP("n",  ";f",    builtin.find_files,           "Search [F]iles")
        SET_MAP("n",  ";r",    builtin.oldfiles,             "Search [R]ecent files")
        SET_MAP("n",  ";w",    builtin.live_grep,            "Search [W]ord")

        SET_MAP("n", ";g", function()
          require("telescope.builtin").git_files({
            git_command = { "git", "diff", "--name-only", "main" },
            prompt_title = "Git changes vs main"
          })
        end, "Search [G]it changes vs main")
		-- stylua: ignore end
	end,
}
