vim.opt.mouse = "a" -- allow the mouse to be used in neovim
vim.opt.expandtab = true -- convert tabs to spaces
vim.opt.shiftwidth = 0 -- fallback to tabstop
vim.opt.tabstop = 2 -- insert 2 spaces for a tab
vim.opt.number = true -- set numbered lines
vim.opt.completeopt = { "menu", "menuone", "noselect" } -- nvim-cmp
vim.opt.termguicolors = true -- enable full colors
vim.cmd([[ colorscheme slate ]])
