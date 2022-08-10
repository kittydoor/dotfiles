local status_ok, configs = pcall(require, "nvim-treesitter.configs")
if not status_ok then
  return
end

local parsers_status_ok, parsers = pcall(require, "nvim-treesitter.parsers")
if not parsers_status_ok then
  return
end

configs.setup {
  ensure_installed = "all",
  ignore_install = { "" },
  highlight = {
    enable = true,
    disable = { "" },
  },
  indent = {
    enable = true,
    disable = { "" },
  },
}
