local opt = vim.opt

-- Auto refresh
vim.opt.autoread = true

-- line #s
opt.relativenumber = true
opt.number = true
opt.colorcolumn = "80"

-- tabs & indentation
opt.tabstop = 4
opt.shiftwidth = 4
opt.expandtab = true
opt.autoindent = true

opt.wrap = false

opt.ignorecase = true
opt.smartcase = true

opt.cursorline = true

-- appearance
opt.termguicolors = true
opt.background = "dark"
opt.signcolumn = "yes"

opt.backspace = "indent,eol,start"

opt.clipboard:append("unnamedplus")

opt.splitright = true
opt.splitbelow = true

opt.iskeyword:append("-")

opt.fillchars = { eob = " " }
opt.swapfile = false

-- Folding stuff
opt.foldcolumn = "1"
opt.foldlevel = 99
opt.foldenable = false
opt.fillchars = {
	foldopen = "",
	foldclose = "",
	fold = " ",
	foldsep = " ",
	diff = "╱",
	eob = " ",
}

opt.conceallevel = 1

opt.spelllang = { "en_us" }
opt.textwidth = 80

vim.filetype.add({
	extension = {
		conf = "conf",
		zsh = "sh",
	},
	filename = {
		[".zsh"] = "sh",
		["tsconfig.json"] = "jsonc",
		[".yamlfmt"] = "yaml",
	},
})

vim.opt.laststatus = 3
-- opt.mouse = "" -- disable mouse
