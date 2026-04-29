vim.g.mapleader = " "

--- Sets a keymap
---
--- @param mode string | string[]
--- @param key string
--- @param action string | function
--- @param description string
function SET_MAP(mode, key, action, description)
	local opts = { noremap = true, silent = true, desc = description }
	vim.keymap.set(mode, key, action, opts)
end

-- stylua: ignore start
SET_MAP("n", "gco", "o<esc>Vcx<esc><cmd>normal gcc<cr>fxa<bs>",   "Add Comment Below" )
SET_MAP("n", "gcO", "O<esc>Vcx<esc><cmd>normal gcc<cr>fxa<bs>",   "Add Comment Above" )

SET_MAP("v", "<A-k>", ":m '<-2<CR>gv=gv",                "Move line up")
SET_MAP("v", "˚",     ":m '<-2<CR>gv=gv",                "Move line up")
SET_MAP("v", "<A-j>", ":m '>+1<CR>gv=gv",                "Move line down")
SET_MAP("v", "∆",     ":m '>+1<CR>gv=gv",                "Move line down")

SET_MAP("n", "<leader>`", [[ciw``<Esc>P]],               "Surround `word`")
SET_MAP("n", '<leader>"', [[ciw""<Esc>P]],               'Surround "word"')
SET_MAP("n", '<leader>{', [[ciw{}<Esc>P]],               "Surround {word}")
SET_MAP("n", '<leader>(', [[ciw()<Esc>P]],               "Surround (word)")

SET_MAP("n", "<C-s>", "<cmd>Neotree toggle<cr>",         "Toggle file explorer")

-- Switch buffers (tab)
SET_MAP("n", "<leader>x", function()
    require("mini.bufremove").delete(0, true)
end,                                                     "Delete Buffer (Force)")
SET_MAP("n", "<leader>bp", ":BufferLineTogglePin<CR>",   "Create [B]uffer [P]in")
SET_MAP("n", "<leader>bu", ":BufferLineCloseOthers<CR>", "Delete [B]uffers [U]npinned" )
SET_MAP("n", "<leader>br", ":BufferLineCloseRight<CR>",  "Delete [B]uffers to [R]ight")
SET_MAP("n", "<leader>bl", ":BufferLineCloseLeft<CR>",   "Delete [B]uffers to [L]eft")
SET_MAP("n", "<tab>",      ":BufferLineCycleNext<CR>",   "Next Buffer")
SET_MAP("n", "<s-tab>",    ":BufferLineCyclePrev<CR>",   "Prev Buffer")

SET_MAP( { "n", "v" }, "<C-h>", ":wincmd h<CR>",         "Move Left")
SET_MAP( { "n", "v" }, "<C-j>", ":wincmd j<CR>",         "Move Down")
SET_MAP( { "n", "v" }, "<C-k>", ":wincmd k<CR>",         "Move Up")
SET_MAP( { "n", "v" }, "<C-l>", ":wincmd l<CR>",         "Move Right")
SET_MAP( "i", "<C-h>", "<esc>:wincmd h<CR>",             "Move Left")
SET_MAP( "i", "<C-j>", "<esc>:wincmd j<CR>",             "Move Down")
SET_MAP( "i", "<C-k>", "<esc>:wincmd k<CR>",             "Move Up")
SET_MAP( "i", "<C-l>", "<esc>:wincmd l<CR>",             "Move Right")

-- Window management (;)
SET_MAP("n", ";v", "<C-w>v",                             "Make Split [V]ertically")
SET_MAP("n", ";h", "<C-w>s",                             "Make Split [H]orizontally")
SET_MAP("n", ";e", "<C-w>=",                             "Make Split [E]qual Size")
SET_MAP("n", ";c", "<cmd>close<CR>",                     "[C]lose Current Split")
--
SET_MAP("n", ";t", "<cmd>TodoTelescope<cr>",             "Find [T]ODOs")
SET_MAP("n", ";o", require("gilad.util.outline").open,   "Open [O]utline")

SET_MAP("n", "<leader>w", function()
	vim.wo.wrap = not vim.wo.wrap
end,                                                     "Toggle [W]rap")

SET_MAP("n", "<leader>e", function()
	vim.diagnostic.open_float({ scope = "line" }, 0)
end,                                                     "Show Line [E]rrors")

SET_MAP("n", "<leader>lr", ":LspRestart<CR>",            "[L]SP [R]estart")
SET_MAP("n", "<leader>li", ":LspInfo<CR>",               "[L]SP [I]nfo")
SET_MAP("n", "<leader>lc", ":ConformInfo<CR>",           "[L]SP [C]onformInfo")
SET_MAP("n", "<leader>ll", ":Lazy<CR>",                  "[L]azy")

SET_MAP("i", "jk", "<Esc>",                              "Exit Insert Mode")

SET_MAP("n", "<leader>ccc", ":CopilotChat<CR>",           "[C]opilot [C]hat")
SET_MAP("n", "<leader>ccr", ":CopilotChatRest<CR>",       "[C]opilot [C]hat [R]eset")
SET_MAP("n", "<leader>cce", ":CopilotChatExplain<CR>",    "[C]opilot [C]hat [E]xplain")
SET_MAP("n", "<leader>ccf", ":CopilotChatFix<CR>",        "[C]opilot [C]hat [F]ix")
SET_MAP("n", "<leader>cco", ":CopilotChatOptimize<CR>",   "[C]opilot [C]hat [O]ptimize")
SET_MAP("n", "<leader>ccd", ":CopilotChatDocs<CR>",       "[C]opilot [C]hat [D]ocs")
SET_MAP("n", "<leader>cct", ":CopilotChatTests<CR>",      "[C]opilot [C]hat [T]ests")
SET_MAP("n", "<leader>ccd", ":CopilotChatDiagnostic<CR>", "[C]opilot [C]hat [D]iagnostic")
SET_MAP("n", "<leader>ccm", ":CopilotChatModel<CR>",      "[C]urrent [C]hat [M]odel")
SET_MAP("n", "<leader>ccM", ":CopilotChatModels<CR>",     "[C]hange [C]hat [M]odel")

SET_MAP("n", "<leader>gw", ":Gitsigns toggle_word_diff<CR>", "[G]it [B]lame [W]ork")


SET_MAP({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, "[C]ode [A]ctions Available")
SET_MAP("n", "<leader>cr", vim.lsp.buf.rename,               "[C]ode [R]ename")

SET_MAP("n", "<leader>W", ":noautocmd w<CR>", "[W]rite no format")
-- stylua: ignore end
