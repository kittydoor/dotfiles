My dotfiles

Quick start:
```shell
# List packages
./dotman

# Install a certain package
./dotman <package name>
```

Package name is the name of the directory inside packages/ (e.g. common)

| Package    | Description                                          |
| ---------- | ---------------------------------------------------- |
| common     | Contains configs common for all Linux systems        |
| core, gate | Host specific configurations                         |
| darwin     | Contains MacOS / Darwin specific configs, special[1] |
| managed-wip     | Contains dotfiles that require configuration management[2] |

[1] Some configs are symlinks to common package

[2] Dotfiles such as mimeapps.list which would require certain packages to be installed or break the system

# Troubleshooting

## Finding broken symlinks

Over time, configuration drift can happen.
A major cause for this is configuration files you have already installed being removed from here.
Major refactors of packages will also cause this to happen.

In order to clean up, find is a very useful tool.
Here are some tips in how to use it.

```shell
# Find all broken symlinks in home (symlinks, which when evaluated will end on a symlink)
find ~ -xtype l

# Ignore a folder with unrelated symlinks (symlink used for sockets, lock files, etc)
find ~ -path '*/folder_name' -prune -o -xtype l -print

# Ignore multiple folders
find ~ \( -path '*/folder_name' -o -path '*/other_folder' \) -prune -o -xtype l -print

# There is a catch with using '*/folder_name/*' vs '*/folder_name/' vs '*/folder_name'
# For most usecases, uuh, I'd just advice you to ignore this.
```
