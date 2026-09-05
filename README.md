# Neovim config

Python/Django/FastAPI-focused IDE setup. Neovim 0.12+, `lazy.nvim`, native `vim.lsp.config`.

## Install on a new machine

```sh
sudo pacman -S neovim git ripgrep fd fzf lazygit nodejs npm gcc unzip
git clone <this-repo> ~/.config/nvim
nvim
```

First launch installs every plugin, language server, formatter, and Treesitter parser
unattended. Give it a few minutes, then restart. `:checkhealth` afterwards.

Python projects need a venv in the project root so the language server resolves imports:

```sh
uv venv && uv sync
```

## Layout

| Path | Contents |
|---|---|
| `lua/config/options.lua` | Editor settings, diagnostics display |
| `lua/config/keymaps.lua` | Non-plugin keymaps |
| `lua/config/autocmds.lua` | Per-language indents, cursor restore, dependency check |
| `lua/config/links.lua` | **Bookmarks for `<leader>o` — edit this to add your own** |
| `lua/config/venv.lua` | Python interpreter detection |
| `lua/config/run.lua` | `<leader>r` compile-and-run commands |
| `lua/config/open.lua` | Smart `gx` (path → Neovim, URL → browser) |
| `lua/plugins/` | One file per concern |

## Keymaps

Leader is `<Space>`. Press it and wait — which-key lists everything.

### Files and search
| Key | Action |
|---|---|
| `<leader>ff` | Find files |
| `<leader>fg` | Grep project |
| `<leader>fw` | Grep word under cursor |
| `<leader>fr` | Recent files |
| `<leader>fb` | Search in current buffer |
| `<leader>,` | Switch buffer |
| `<leader>fR` | Resume last picker |
| `<leader>sr` | Project find and replace |
| `<leader>st` | TODO comments |
| `<leader>e` | File explorer sidebar |
| `<leader>E` | Explorer, revealing current file |
| `-` | Edit the current directory as a buffer (oil) |

### Git
| Key | Action |
|---|---|
| `<leader>gg` | **lazygit** |
| `<leader>gf` | Changed files |
| `<leader>gG` | Grep **only** changed files |
| `<leader>gc` / `<leader>gC` | Commits: project / current file |
| `<leader>gh` | Branches |
| `<leader>gS` | Stashes |
| `<leader>ge` | Explorer, git-status view |
| `]h` / `[h` | Next / previous hunk |
| `<leader>gs` / `<leader>gr` | Stage / reset hunk |
| `<leader>gp` | Preview hunk inline |
| `<leader>gb` / `<leader>gB` | Blame line / file |
| `<leader>gd` | Diff against index |

### Code
| Key | Action |
|---|---|
| `gd` / `gD` / `gy` | Definition / declaration / type definition |
| `grr` / `grn` / `gra` | References / rename / code action *(Neovim defaults)* |
| `K` | Hover docs |
| `<leader>cd` | Line diagnostics |
| `<leader>cf` | Format now |
| `<leader>cv` | Select Python venv |
| `<leader>xx` / `<leader>xX` | Diagnostics: project / buffer |
| `<leader>xs` | Symbols outline |
| `af` `if` `ac` `ic` `aa` `ia` | Function / class / parameter text objects |
| `]f` `[f` `]]` `[[` | Jump between functions / classes |

### Completion
| Key | Action |
|---|---|
| `<CR>` | **Accept** |
| `<C-j>` / `<C-k>` | **Next / previous item** |
| `<C-y>` | Accept (also works) |
| `<C-n>` / `<C-p>` | Next / previous item (also works) |
| `<C-Space>` | Open menu |
| `<C-e>` | Dismiss — press this first if you want a newline, not the completion |
| `<C-b>` / `<C-f>` | Scroll the docs popup |
| `<Tab>` | Accept Copilot suggestion, else jump to next snippet field |
| `<M-]>` / `<M-[>` | Cycle Copilot suggestions |

The first item is preselected, so `<CR>` accepts as soon as the menu is open.
That is the tradeoff for Enter-to-accept: to insert a newline while the menu is
showing, dismiss it with `<C-e>` first.

### Toggles
| Key | Action |
|---|---|
| `<leader>ua` | **Copilot on/off** (starts off) |
| `<leader>uf` | Format on save on/off |
| `<leader>uh` | Inlay hints |
| `<leader>ub` | Inline git blame |
| `<leader>um` | Markdown rendering |
| `<leader>un` | Dismiss notifications |
| `<leader>?` | **All keybinds (cheatsheet)** |

### Misc
| Key | Action |
|---|---|
| `<leader>r` | Run current file in a split |
| `<leader>o` | Open a bookmark in the browser |
| `gx` | Open path or URL under the cursor |
| `<leader>D` | Database UI |
| `<leader>Rs` | Send HTTP request *(in `.http` files)* |
| `<leader>uu` | Undo history |
| `<leader>qs` / `<leader>ql` | Restore session: this directory / last |
| `jk` | Exit insert mode |
| `<C-s>` | Save |
| `s` / `S` | Flash jump / treesitter jump |

## Notes

- Copilot needs `:Copilot auth` once.
- Neovim's internal `'shell'` is bash (fish is not POSIX and breaks plugin subprocesses);
  `:terminal` is unaffected.
- Add a database connection with `:DBUIAddConnection`, e.g.
  `postgresql://user:pass@localhost:5432/dbname`.
