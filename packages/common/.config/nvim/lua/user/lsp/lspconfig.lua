local lspconfig_status_ok, lspconfig = pcall(require, "lspconfig")
if not lspconfig_status_ok then
  return
end

local mason_lspconfig_status_ok, mason_lspconfig = pcall(require, "mason-lspconfig")
if not mason_lspconfig_status_ok then
  return
end

local servers = {
  "ansiblels",
  "bashls",
  "dockerls",
  "gopls",
  "jsonls",
  "pylsp",
  "rust_analyzer",
  "salt_ls",
  "sumneko_lua",
  "terraformls",
  "tflint",
  "vimls",
  "yamlls",
}

require("mason").setup()
mason_lspconfig.setup {
  automatic_installation = true,
}

for _, server in pairs(servers) do
  local opts = {
    on_attach = require("user.lsp.handlers").on_attach,
    capabilities = require("user.lsp.handlers").capabilities,
  }

  if server == "sumneko_lua" then
    opts = vim.tbl_deep_extend("force",
      {
        settings = {
          Lua = {
            diagnostics = {
              globals = { "vim" },
            },
            workspace = {
              library = {
                [vim.fn.expand("$VIMRUNTIME/lua")] = true,
                [vim.fn.stdpath("config") .. "/lua"] = true,
              },
            },
            telemetry = {
              enable = false,
            },
          },
        },
      }, opts)
  end

  if server == "terraformls" then
    opts = vim.tbl_deep_extend("force",
      {
        -- For some reason settings = { ['terraform-ls'] = { is not respected
        init_options = {
          experimentalFeatures = {
            validateOnSave = true,
          },
        },
      }, opts)
  end

  lspconfig[server].setup(opts)
end
