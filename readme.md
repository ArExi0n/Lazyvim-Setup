# Neovim Keybindings

> Leader key: `<Space>`

---

## File Explorer

| Key | Action |
|-----|--------|
| `<leader>pv` | Toggle file explorer (Neotree) |

## LSP / Code Navigation

| Key | Action |
|-----|--------|
| `gd` | Line diagnostics (float) |
| `<leader>gd` | Go to definition |
| `gD` | Go to declaration |
| `gi` | Go to implementation |
| `gr` | Find references |
| `K` | Hover documentation |
| `<leader>vws` | Workspace symbols |
| `[d` | Previous diagnostic |
| `]d` | Next diagnostic |
| `<leader>vca` | Code action |
| `<leader>vrr` | References |
| `<leader>vrn` | Rename symbol |
| `<C-h>` (insert) | Signature help |
| `<leader>f` | Format buffer |
| `<leader>zig` | Restart LSP |

## Telescope

| Key | Action |
|-----|--------|
| `;f` | Find files (hidden included) |
| `<leader>ff` | Find files |
| `<C-S>` | Git files |
| `;r` | Live grep |
| `<leader>ps` | Grep search (prompt) |
| `<leader>pws` | Grep word under cursor |
| `<leader>pWs` | Grep WORD under cursor |
| `\\` | Buffers list |
| `;;` | Resume picker |
| `;e` | Diagnostics |
| `;s` | Treesitter symbols |
| `<leader>vh` | Help tags |
| `sf` | File browser |

## Harpoon

| Key | Action |
|-----|--------|
| `<leader>a` | Add file to harpoon |
| `<C-p>` | Toggle harpoon menu |
| `<leader>1` | Select file 1 |
| `<leader>2` | Select file 2 |
| `<leader>3` | Select file 3 |
| `<leader>4` | Select file 4 |
| `<C-B>` | Previous harpoon file |
| `<C-N>` | Next harpoon file |

## Debugging (DAP)

| Key | Action |
|-----|--------|
| `<leader>dd` | Build & debug (Xcode) |
| `<leader>dr` | Debug without building |
| `<leader>dt` | Debug tests |
| `<leader>dT` | Debug class tests |
| `<leader>b` | Toggle breakpoint |
| `<leader>B` | Toggle message breakpoint |
| `<leader>dx` | Terminate debugger |
| `<leader>dc` | Continue |
| `<leader>dC` | Run to cursor |
| `<leader>ds` | Step over |
| `<leader>di` | Step into |
| `<leader>do` | Step out |
| `<leader>dh` | Hover (widget) |
| `<leader>de` | Eval (dapui) |
| `<leader>du` | Toggle DAP UI |
| `<leader>dw` | Add watch |
| `<leader>dW` | Remove watch |
| `<leader>dCC` | Clear watches |

## Xcode Build

| Key | Action |
|-----|--------|
| `<leader>X` | Show Xcodebuild actions picker |
| `<leader>xf` | Project manager |
| `<leader>xb` | Build project |
| `<leader>xB` | Build for testing |
| `<leader>xr` | Build & run |
| `<leader>xt` | Run tests |
| `<leader>xT` | Run test class |
| `<leader>xl` | Toggle logs |
| `<leader>xc` | Toggle code coverage |
| `<leader>xC` | Show code coverage report |
| `<leader>xe` | Toggle test explorer |
| `<leader>xs` | Show failing snapshots |
| `<leader>xd` | Select device |
| `<leader>xp` | Select test plan |
| `<leader>xq` | Show quickfix list |
| `<leader>xx` | Quickfix line |
| `<leader>xa` | Show code actions |

## Tests (Neotest)

| Key | Action |
|-----|--------|
| `;tt` | Run test file |
| `;tr` | Run nearest test |
| `;tT` | Run all test files |
| `;tl` | Run last test |
| `;ts` | Toggle test summary |
| `;to` | Show test output |
| `;tO` | Toggle output panel |
| `;tS` | Stop test run |
| `<leader>tf` | Plenary test file |

## Refactoring

| Key | Action |
|-----|--------|
| `<leader>rn` | Incremental rename |
| `<leader>r` (visual) | Select refactor action |
| `<leader>re` (visual) | Extract function |
| `<leader>rf` (visual) | Extract to file |
| `<leader>rv` (visual) | Extract variable |
| `<leader>ri` | Inline variable |
| `<leader>rI` | Inline function |
| `<leader>rb` | Extract block |
| `<leader>rbf` | Extract block to file |

## Quickfix / Location List

| Key | Action |
|-----|--------|
| `<C-k>` | Next quickfix |
| `<C-j>` | Previous quickfix |
| `<leader>k` | Next location |
| `<leader>j` | Previous location |
| `<leader>tt` | Toggle trouble quickfix |

## Buffer Navigation

| Key | Action |
|-----|--------|
| `<Tab>` | Next buffer |
| `<S-Tab>` | Previous buffer |

## Editing

| Key | Action |
|-----|--------|
| `J` (visual) | Move line down |
| `K` (visual) | Move line up |
| `J` (normal) | Join lines, keep cursor |
| `<C-d>` | Page down, center |
| `<C-u>` | Page up, center |
| `n` | Next search, center |
| `N` | Prev search, center |
| `=ap` | Re-indent paragraph |
| `<leader>p` (visual) | Paste without yanking |
| `<leader>y` | Yank to system clipboard |
| `<leader>Y` | Yank line to system clipboard |
| `<leader>d` | Delete without yanking |
| `<C-c>` (insert) | Escape |
| `Q` | Disabled (no Ex mode) |
| `<leader>s` | Search & replace word under cursor |
| `<leader>x` | Make file executable |
| `<leader><leader>` | Reload config |

## Typst

| Key | Action |
|-----|--------|
| `<leader>tp` | Start Typst preview |
| `<leader>tP` | Stop Typst preview |
| `<leader>te` | Export Typst PDF |
| `<leader>tv` | Open Typst PDF in sioyek |

## Obsidian

| Key | Action |
|-----|--------|
| `<leader>ob` | Backlinks |
| `<leader>od` | Daily note |
| `<leader>ol` | Note links |
| `<leader>oo` | Open in Obsidian |
| `<leader>oq` | Quick switch |
| `<leader>os` | Search notes |
| `<leader>ot` | Insert template |
| `<leader>oT` | Table of contents |

## Other

| Key | Action |
|-----|--------|
| `<leader>u` | Toggle undotree |
| `<leader>ts` | Select theme |
| `<leader>tn` | Next theme |
| `<leader>ca` | Make it rain (cellular-automaton) |
| `<leader>vwm` | Start Vim With Me |
| `<leader>svwm` | Stop Vim With Me |
| `<leader>apm` | Show APM |
| `;c` | Open LazyGit |
| `<leader>d` | Open DBUI |
| `\\r` | Test current REST file |
| `<C-f>` | Open tmux sessionizer |
| `<M-h>` | Open tmux sessionizer (vsplit) |
| `<M-H>` | Open tmux sessionizer (new window) |

## Go Error Helpers

| Key | Action |
|-----|--------|
| `<leader>ee` | Insert `if err != nil { return err }` |
| `<leader>ea` | Insert `assert.NoError` |
| `<leader>ef` | Insert `log.Fatalf` error check |
| `<leader>el` | Insert `logger.Error` |

## Treesitter Text Objects

| Key | Action |
|-----|--------|
| `<C-space>` | Increment selection |
| `<BS>` (visual) | Decrement selection |
| `af`/`if` | Around/inside function |
| `ac`/`ic` | Around/inside class |
| `]f` / `[f` | Next/prev function start |
| `]F` / `[F` | Next/prev function end |
| `]c` / `[c` | Next/prev class start |
| `]C` / `[C` | Next/prev class end |

## Misc

| Key | Action |
|-----|--------|
| `<C-j>` / `<C-k>` (telescope) | Move selection next/prev |
| `N` (file browser) | Create file |
| `h` (file browser) | Go to parent directory |
| `t` (nvim-tree) | Open in tab |
| `q` / `<Esc>` (dapui float) | Close floating window |
