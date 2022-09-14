local status_ok, mason = pcall(require, "mason")
if not status_ok then
  return
end

mason.setup()

local mason_tool_installer_status_ok, mason_tool_intaller = pcall(require, "mason-tool-installer")
if not mason_tool_installer_status_ok then
  return
end

mason_tool_intaller.setup {
  ensure_installed = {
    'golangci-lint',
    'vim-language-server',
    'gopls',
    'stylua',
    'shellcheck',
    'editorconfig-checker',
    'gofumpt',
    'luacheck',
    'pylint',
    'shellcheck',
    'shellharden',
    'shfmt',
    'staticcheck',
    -- 'golines',
    -- 'gomodifytags',
    -- 'gotests',
    -- 'impl',
    -- 'json-to-struct',
    -- 'misspell',
    -- 'revive',
    -- 'vint',
  },
  auto_update = true,
}
