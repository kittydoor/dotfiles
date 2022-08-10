local lspconfig_status_ok, lspconfig = pcall(require, "lspconfig")
if not lspconfig_status_ok then
  return
end

local mason_lspconfig_status_ok, mason_lspconfig = pcall(require, "mason-lspconfig")
if not mason_lspconfig_status_ok then
  return
end

local servers = {
  "bashls",
  "yamlls",
  "jsonls",
  "pylsp",
  "sumneko_lua",
  "dockerls",
  "ansiblels",
  "rust_analyzer",
  "salt_ls",
  "terraformls",
  "tflint",
  "vimls",
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

  lspconfig[server].setup(opts)
end
