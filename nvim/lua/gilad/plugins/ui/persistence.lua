-- Load and save session data

return {
	"folke/persistence.nvim",
	event = "BufReadPre",
	opts = {
		options = vim.opt.sessionoptions:get(),
		pre_save = function()
			vim.cmd("Neotree close")
		end,
	},
}
