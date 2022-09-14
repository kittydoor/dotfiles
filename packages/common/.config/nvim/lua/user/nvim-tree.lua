local status_ok, nvim_tree = pcall(require, "nvim-tree")
if not status_ok then
  return
end

nvim_tree.setup {
  view = {
    signcolumn = "no",
    mappings = {
      list = {
        { key = "s", action = "split" },
        { key = "v", action = "vsplit" }
      }
    }
  },
  renderer = {
    add_trailing = true,
    group_empty = true,
    indent_markers = {
      enable = true,
    },
    icons = {
      padding = "",
      symlink_arrow = " -> ",
      show = {
        file = false,
        folder = false,
        folder_arrow = true,
        git = false,
      },
      glyphs = {
        folder = {
          default = "",
          arrow_closed = "▸",
          arrow_open = "▾",
          open = "",
          empty = "",
          empty_open = "",
          symlink = "",
          symlink_open = "",
        },
        symlink = "",
      }
    }
  }
}
