vim.api.nvim_create_user_command("Pwdc", function()
	local filepath = vim.fn.expand("%:p") -- Removed :h to get full file path
	if filepath == "" then
		print("No file in current buffer")
		return
	end

	vim.fn.setreg("+", filepath)
	print("Copied to clipboard: " .. filepath)
end, {})
