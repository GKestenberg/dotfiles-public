vim.api.nvim_create_user_command("Pwdc", function()
	local filepath = vim.fn.expand("%:p") -- Removed :h to get full file path
	if filepath == "" then
		print("No file in current buffer")
		return
	end

	local relative = filepath:match(".*/workstation/(.+)$") or filepath
	vim.fn.setreg("+", relative)
	print("Copied to clipboard: " .. relative)
end, {})
