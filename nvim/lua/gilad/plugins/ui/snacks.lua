local terminals = {}

-- open multiple terminals
for i = 0, 9 do
	SET_MAP("n", "<leader>t" .. i, function()
		if terminals[i] then
			terminals[i]:show()
		else
			terminals[i] = require("snacks").terminal.open()
		end
	end, "Open Terminal " .. i)
end
SET_MAP("t", "<C-x>", function()
	vim.cmd("stopinsert")
	vim.cmd("close")
end, "Exit Terminal")

return {
	"folke/snacks.nvim",
	priority = 1000,
	lazy = false,
	---@type snacks.Config
	opts = {
		bigfile = { enabled = true }, -- turns off lsp for big files
		notifier = { enabled = true }, -- changes vim.notify
		lazygit = { enabled = true },
		quickfix = { enabled = true },
		quickfile = { enabled = true }, -- optimizes `nvim <filename>` rendering
		words = { enabled = true },
		terminal = {},
		dashboard = {
			enabled = true,
			preset = {
				header = [[
 ██████╗ ██╗██╗      █████╗ ██████╗     ██╗   ██╗██╗███╗   ███╗ 
██╔════╝ ██║██║     ██╔══██╗██╔══██╗    ██║   ██║██║████╗ ████║ 
██║  ███╗██║██║     ███████║██║  ██║    ██║   ██║██║██╔████╔██║ 
██║   ██║██║██║     ██╔══██║██║  ██║    ╚██╗ ██╔╝██║██║╚██╔╝██║ 
╚██████╔╝██║███████╗██║  ██║██████╔╝     ╚████╔╝ ██║██║ ╚═╝ ██║ 
 ╚═════╝ ╚═╝╚══════╝╚═╝  ╚═╝╚═════╝       ╚═══╝  ╚═╝╚═╝     ╚═╝ 
                ]],
				keys = {
                    -- stylua: ignore start
					{ icon = " ", key = "f", desc = "Find [F]ile",       action = ":lua Snacks.dashboard.pick('files')" },
					{ icon = " ", key = "n", desc = "[N]ew File",        action = ":ene | startinsert" },
					{ icon = " ", key = "w", desc = "Find [W]ord",       action = ":lua Snacks.dashboard.pick('live_grep')" },
					{ icon = " ", key = "r", desc = "[R]ecent Files",    action = ":lua Snacks.dashboard.pick('oldfiles')" },
					{ icon = " ", key = "c", desc = "[C]onfig",          action = ":lua Snacks.dashboard.pick('files', {cwd = vim.fn.stdpath('config')})" },
					{ icon = " ", key = "s", desc = "Restore [S]ession", section = "session" },
					{ icon = "󰒲 ", key = "L", desc = "[L]azy",            action = ":Lazy", enabled = package.loaded.lazy ~= nil },
					{ icon = " ", key = "q", desc = "[Q]uit",            action = ":qa" },
					-- stylua: ignore end
				},
			},
		},
	},
	keys = {
        -- stylua: ignore start
        { "<leader>gg", function() require("snacks").lazygit.open() end,            desc = "Toggle Lazy[G]it" },
        { "<leader>gb", function() require("snacks").git.blame_line() end,          desc = "[G]it [B]lame Line" },
        { "<leader>gB", function() require("snacks").gitbrowse() end,               desc = "[G]it [B]rowse" },
        { "<leader>gl", function() require("snacks").lazygit.log() end,             desc = "[G]it [L]og" },

        { "<leader>nh", function() require("snacks").notifier.show_history() end,   desc = "[N]otification [H]istory" },
        { "<leader>nd", function() require("snacks").notifier.hide() end,           desc = "[N]otifications [D]ismiss" },

        { "<leader>cR", function() require("snacks").rename.rename_file() end,      desc = "[R]ename File" },

        { "]]",         function() require("snacks").words.jump(vim.v.count1) end,  desc = "Next Reference", mode = { "n", "t" } },
        { "[[",         function() require("snacks").words.jump(-vim.v.count1) end, desc = "Prev Reference", mode = { "n", "t" } },
		-- stylua: ignore end
	},
}
