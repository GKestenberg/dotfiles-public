vim.api.nvim_create_user_command("Pwdc", function()
	local filepath = vim.fn.expand("%:p")
	if filepath == "" then
		print("No file in current buffer")
		return
	end
	local home = vim.loop.os_homedir() or os.getenv("HOME") or ""
	local relative = filepath:match(".*/workstation/(.+)$")
		or (home ~= "" and filepath:sub(1, #home) == home and "~" .. filepath:sub(#home + 1))
		or filepath
	vim.fn.setreg("+", relative)
	print("Copied to clipboard: " .. relative)
end, {})
