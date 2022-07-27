local null_ls_status_ok, null_ls = pcall(require, "null-ls")
if not null_ls_status_ok then
  return
end

local formatting = null_ls.builtins.formatting
local diagnostics = null_ls.builtins.diagnostics

null_ls.setup {
  debug = true,
  sources = {
    formatting.stylua,
    -- diagnostics.actionlint,
    diagnostics.pylint,
    diagnostics.golangci_lint,
    -- diagnostics.ansiblelint,
    -- diagnostics.checkmake,
    -- diagnostics.chktex,
    -- diagnostics.codespell,
    -- diagnostics.luacheck,
    -- diagnostics.markdownlint,
    diagnostics.shellcheck,
    -- diagnostics.staticcheck,
    -- diagnostics.statix,
    -- diagnostics.yamllint,
    diagnostics.zsh,
    -- formatting.black,
    -- formatting.gofmt,
    -- formatting.gofumpt,
    -- formatting.jq,
    -- formatting.lua_format
  },
}
