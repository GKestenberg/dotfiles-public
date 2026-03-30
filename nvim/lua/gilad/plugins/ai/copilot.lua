-- GitHub Copilot uses OpenAI Codex to suggest code and entire functions in
-- real-time right from your editor.

return {
	-- {
	-- 	"zbirenbaum/copilot.lua",
	-- 	event = "InsertEnter",
	-- 	opts = {
	-- 		suggestion = {
	-- 			enabled = true,
	-- 			auto_trigger = true,
	-- 			debounce = 75,
	-- 			keymap = {
	-- 				accept = "<C-e>",
	-- 				accept_word = false,
	-- 				accept_line = false,
	-- 			},
	-- 		},
	-- 		filetypes = { svelte = true, markdown = true, yaml = true, dotenv = false },
	-- 		keys = {
	-- 			accept = "<C-e>",
	-- 		},
	-- 	},
	-- },
	{
		"supermaven-inc/supermaven-nvim",
		opts = { keymaps = { accept_suggestion = "<C-e>" } },
		config = function(_, opts)
			require("supermaven-nvim").setup(opts)
		end,
	},
}
