local M = {}

function M.open()
	if vim.bo.filetype == "dart" then
		require("flutter-tools.outline").toggle()
	else
		vim.cmd("SymbolsOutline")
	end
end

return M
