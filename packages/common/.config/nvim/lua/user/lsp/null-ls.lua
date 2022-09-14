local null_ls_status_ok, null_ls = pcall(require, "null-ls")
if not null_ls_status_ok then
  return
end

local formatting = null_ls.builtins.formatting
local diagnostics = null_ls.builtins.diagnostics

null_ls.setup {
  debug = true,
  sources = {
    diagnostics.pylint,
    diagnostics.golangci_lint,
    diagnostics.shellcheck,
    diagnostics.zsh,
    formatting.terraform_fmt,
    formatting.gofumpt,
    formatting.shellharden,
    -- diagnostics.actionlint,
    -- diagnostics.ansiblelint,
    -- diagnostics.chktex,
    -- diagnostics.codespell,
    -- diagnostics.luacheck,
    -- diagnostics.markdownlint,
    -- diagnostics.staticcheck,
    -- diagnostics.statix,
    -- diagnostics.yamllint,
    -- formatting.black,
    -- formatting.gofmt,
    -- formatting.jq,
    -- formatting.lua_format
    -- formatting.shfmt
    -- formatting.stylua,
  },
}
