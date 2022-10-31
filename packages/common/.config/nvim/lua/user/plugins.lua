local fn = vim.fn

-- Automatically install packer
local install_path = fn.stdpath "data" .. "/site/pack/packer/start/packer.nvim"
if fn.empty(fn.glob(install_path)) > 0 then
  PACKER_BOOTSTRAP = fn.system {
    "git",
    "clone",
    "--depth",
    "1",
    "https://github.com/wbthomason/packer.nvim",
    install_path,
  }
  print "Installing packer close and reopen Neovim..."
  vim.cmd [[packadd packer.nvim]]
end

-- Autocommand that reloads neovim whenever you save the plugins.lua file
vim.cmd [[
  augroup packer_user_config
    autocmd!
    autocmd BufWritePost plugins.lua source <afile> | PackerSync
  augroup end
]]

-- Use a protected call so we don't error out on first use
local status_ok, packer = pcall(require, "packer")
if not status_ok then
  return
end

-- Have packer use a popup window
packer.init {
  display = {
    open_fn = function()
      return require("packer.util").float { border = "rounded" }
    end,
  },
}

-- Install your plugins here
return packer.startup(function(use)
  -- My plugins here
  use "wbthomason/packer.nvim" -- Have packer manage itself
  use "nvim-lua/plenary.nvim" -- Useful lua functions used by lots of plugins

  -- TODO: Consider vim-sleuth instead
  use "editorconfig/editorconfig-vim" -- Official editorconfig plugin

  use "williamboman/mason.nvim" -- Package Manager (for LSP and linters and etc.)
  use "williamboman/mason-lspconfig.nvim" -- Hook mason into lspconfig automatically
  use "WhoIsSethDaniel/mason-tool-installer.nvim" -- Install missing tools from a base list
  use "neovim/nvim-lspconfig" -- Add default (prebuilt) defaults for easily configuring LSPs

  use "hrsh7th/cmp-nvim-lsp" -- Hook cmp into lsp
  use "hrsh7th/cmp-nvim-lua" -- Hook cmp into Lua??
  use "hrsh7th/cmp-buffer" -- Hook cmp into buffer contents
  use "hrsh7th/cmp-path" -- Hook cmp into file path??
  use "hrsh7th/cmp-cmdline" -- Hook cmp into ??
  use "hrsh7th/cmp-git" -- Hook cmp into git??
  use "hrsh7th/nvim-cmp" -- Completion plugin with diverse ecosystem

  use "hrsh7th/cmp-vsnip"
  use "hrsh7th/vim-vsnip"

  -- TODO: Figure out more about text objects
  use "nvim-treesitter/nvim-treesitter" -- Add treesitter syntax highlighting and folds into neovim

  use "sheerun/vim-polyglot" -- Add support for many languages

  use "jose-elias-alvarez/null-ls.nvim" -- Bridge LSP protocol and common linters and other tooling

  -- View all issues (trouble :P) with your code
  use { "folke/trouble.nvim", config = function() require("trouble").setup { icons = false, } end }

  -- use "nvim-tree/nvim-tree.lua" -- Tree style file manager
  use { "nvim-neo-tree/neo-tree.nvim", branch = "v2.x", requires = { "nvim-lua/plenary.nvim", "MunifTanjim/nui.nvim" } }

  use "godlygeek/tabular" -- Manage tables / tabular text

  -- Automatically set up your configuration after cloning packer.nvim
  -- Put this at the end after all plugins
  if PACKER_BOOTSTRAP then
    require("packer").sync()
  end
end)
