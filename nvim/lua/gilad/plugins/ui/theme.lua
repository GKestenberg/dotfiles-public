-- lua/plugins/rose-pine.lua
return {
	"rose-pine/neovim",
	name = "rose-pine",
	config = function()
		local function is_dark_mode()
			local ok, handle = pcall(io.popen, [[defaults read -g AppleInterfaceStyle 2>/dev/null]])
			if not ok or not handle then
				return false
			end
			local result = handle:read("*a")
			handle:close()
			return result:match("Dark") ~= nil
		end
		local current_mode = is_dark_mode()

		local function update_colorscheme()
			if current_mode then
				vim.cmd([[colorscheme rose-pine-moon]])
			else
				vim.cmd("colorscheme rose-pine-dawn")
			end
		end

		vim.fn.timer_start(1000, function()
			local new_mode = is_dark_mode()
			if new_mode ~= current_mode then
				current_mode = new_mode
				update_colorscheme()
			end
		end, { ["repeat"] = -1 })

		vim.api.nvim_create_autocmd("UIEnter", {
			callback = update_colorscheme,
		})
	end,
}

-- return {
-- 	"catppuccin/nvim",
-- 	name = "catppuccin",
-- 	priority = 1000,
-- 	opts = { transparent_background = true },
-- 	config = function(_, opts)
-- 		-- Checks if the system is in dark/light mode and updates the
-- 		-- colorscheme accordingly.
-- 		local function is_dark_mode()
-- 			local ok, handle = pcall(io.popen, [[defaults read -g AppleInterfaceStyle 2>/dev/null]])
-- 			if not ok or not handle then
-- 				return false
-- 			end
-- 			local result = handle:read("*a")
-- 			handle:close()
-- 			return result:match("Dark") ~= nil
-- 		end
--
-- 		local current_mode = is_dark_mode()
--
-- 		local function update_colorscheme()
-- 			opts.transparent_background = current_mode
-- 			require("catppuccin").setup(opts) -- fortunately cat is reentrant
-- 			if current_mode then
-- 				vim.cmd([[colorscheme catppuccin-mocha]])
-- 			else
-- 				vim.cmd("colorscheme catppuccin-latte")
-- 			end
-- 		end
--
-- 		vim.fn.timer_start(1000, function()
-- 			local new_mode = is_dark_mode()
-- 			if new_mode ~= current_mode then
-- 				current_mode = new_mode
-- 				update_colorscheme()
-- 			end
-- 		end, { ["repeat"] = -1 })
--
-- 		vim.api.nvim_create_autocmd("UIEnter", {
-- 			callback = update_colorscheme,
-- 		})
-- 	end,
-- }
