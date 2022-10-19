local status_ok, neo_tree = pcall(require, "neo-tree")
if not status_ok then
  return
end

-- TODO: https://github.com/nvim-neo-tree/neo-tree.nvim/wiki/Recipes#emulating-vims-fold-commands

neo_tree.setup {
  use_popups_for_input = false,
  default_component_configs = {
    indent = {
      padding = 1,
    },
    icon = {
      folder_open = "▾",
      folder_closed = "▸",
      folder_empty = "▸",
      default = "",
    },
    name = {
      trailing_slash = true,
    },
    git_status = {
      symbols = {
        -- Change type
        added = "", -- or "✚", but this is redundant info if you use git_status_colors on the name
        modified = "", -- or "", but this is redundant info if you use git_status_colors on the name
        deleted = "x", -- this can only be used in the git_status source
        renamed = "r", -- this can only be used in the git_status source
        -- Status type
        untracked = "ut",
        ignored = "i",
        unstaged = "us",
        staged = "s",
        conflict = "c",
      },
    },
  },
  window = {
    width = 30,
    mappings = {
      ["w"] = "none",
      ["a"] = {
        "add", nowait = true, config = { show_path = "relative" }
      },
    },
  },
  filesystem = {
    filtered_items = {
      visible = true,
    },
    group_empty_dirs = true,
    hijack_netrw_behavior = "open_default",
  },
}
