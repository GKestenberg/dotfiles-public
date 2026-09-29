-- Language servers installed with `go install`, outside of mason.
--
-- gopls must be built with the same Go toolchain the projects use; mason's
-- prebuilt copy lags and (because core/lsp.lua prepends mason/bin to PATH)
-- silently shadows the one in GOBIN. So gopls is owned here instead:
--   * on startup, install anything in `go_tools` that is missing
--   * `:InstallLsp` re-runs `go install ...@latest` for all of them (update)
--   * the gopls client is pointed at the GOBIN binary by absolute path

local go_tools = {
	gopls = "golang.org/x/tools/gopls@latest",
}

local gobin = os.getenv("GOBIN") or ((os.getenv("GOPATH") or vim.fn.expand("~/go")) .. "/bin")

local function bin(name)
	return gobin .. "/" .. name
end

---@param name string
---@param pkg string
---@param on_done fun(ok: boolean)|nil
local function go_install(name, pkg, on_done)
	vim.notify(("[install-lsp] go install %s"):format(pkg), vim.log.levels.INFO)
	vim.system({ "go", "install", pkg }, { text = true }, function(out)
		vim.schedule(function()
			if out.code == 0 then
				vim.notify(("[install-lsp] installed %s -> %s"):format(name, bin(name)), vim.log.levels.INFO)
			else
				vim.notify(
					("[install-lsp] go install %s failed (%d):\n%s"):format(pkg, out.code, out.stderr or ""),
					vim.log.levels.ERROR
				)
			end
			if on_done then
				on_done(out.code == 0)
			end
		end)
	end)
end

-- Always resolve gopls to GOBIN, regardless of what mason put on PATH.
vim.lsp.config("gopls", { cmd = { bin("gopls") } })

-- Install missing tools once the UI is up; don't block startup.
vim.defer_fn(function()
	if vim.fn.executable("go") ~= 1 then
		vim.notify("[install-lsp] `go` not found on PATH; cannot install " .. vim.inspect(vim.tbl_keys(go_tools)), vim.log.levels.WARN)
		return
	end
	for name, pkg in pairs(go_tools) do
		if vim.fn.executable(bin(name)) ~= 1 then
			go_install(name, pkg)
		end
	end
end, 1000)

vim.api.nvim_create_user_command("InstallLsp", function()
	for name, pkg in pairs(go_tools) do
		go_install(name, pkg, function(ok)
			if ok and name == "gopls" then
				vim.notify("[install-lsp] run :LspRestart gopls to pick up the new binary", vim.log.levels.INFO)
			end
		end)
	end
end, { desc = "go install (update) every go-managed language server" })
