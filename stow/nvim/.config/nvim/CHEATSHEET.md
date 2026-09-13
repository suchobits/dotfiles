# nvim cheatsheet

What is already wired in this config and how to reach it.
Companion to README.md, which explains *why* each piece is here; this file is the *what* and the keys.

The config is [LazyVim](https://www.lazyvim.org/) core + the extras in `lazyvim.json` + the local specs in `lua/plugins/`.

## Finding keys without this file

| Key / cmd | What |
| --- | --- |
| `<leader>` | Space. `<localleader>` is `\`. |
| any prefix, then wait | which-key popup lists what follows (helix preset) |
| `<leader>?` | which-key: keymaps that apply to the current buffer only |
| `<leader>sk` | picker over *every* keymap (fuzzy, jumps to the mapping) |
| `<leader>sh` | picker over help pages |
| `<C-w><space>` | which-key window hydra mode |

## Local tweaks (this repo, not stock LazyVim)

| Key / behaviour | Where |
| --- | --- |
| `jj` / `jk` in insert -> `<Esc>` | `lua/config/keymaps.lua` |
| CLI agents run in a **tmux** pane, survive `:q` | `lua/plugins/sidekick.lua` |
| `<C-hjkl>` crosses nvim splits **and** tmux panes seamlessly | `lua/plugins/tmux-navigator.lua` + `stow/tmux` |
| Spell dictionary is the repo file `spell/en.utf-8.add`, recompiled on save | `options.lua` + `autocmds.lua` |
| snacks explorer/picker **show dotfiles** (`.git` and OS junk still hidden) | `lua/plugins/explorer.lua` |
| Colorscheme is vendored **Vira Carbon** (`vira/`) | `lua/plugins/colorscheme.lua` |
| Dashboard banner is snacks' `NEOVIM`, not `LAZYVIM` | `lua/plugins/dashboard.lua` |
| New empty `*.swift` files get an Xcode header from `templates/swift/` | `lua/plugins/swift.lua` |
| 2s `checktime` timer reloads files changed by Xcode / the simulator | `lua/plugins/swift.lua` |

## Motion and editing

### Flash (`folke/flash.nvim`, core)

| Key | Mode | Action |
| --- | --- | --- |
| `s` | n/x/o | Flash jump: type ~2 chars, then the label |
| `S` | n/x/o | Flash Treesitter: label-select a syntax node |
| `r` | operator-pending | Remote Flash (act on a far location, return) |
| `R` | o/x | Treesitter Search |
| `<C-s>` | command-line | toggle Flash while typing a `/` search (shadowed by the tmux prefix inside tmux) |
| `<C-space>` | n/o/x | Treesitter incremental selection (`<C-space>` grow / `<BS>` shrink) |

Flash also decorates `f` `t` `F` `T` and `/` automatically.

### Windows / buffers / lines (core)

| Key | Action |
| --- | --- |
| `<C-h/j/k/l>` | move to window left/down/up/right - and across into tmux panes at the edge |
| `<C-Up/Down/Left/Right>` | resize window (nvim splits only; tmux panes resize with `<prefix> h/j/k/l`) |
| `:w` | save - buffers autosave a couple of seconds after you stop typing (`auto-save.nvim`, `lua/plugins/autosave.lua`) |
| `<leader>-` / `<leader>\|` | split below / right |
| `<leader>wd` | close window |
| `<leader>wm` | zoom (maximize) window |
| `<S-h>` / `<S-l>`, `[b` / `]b` | prev / next buffer |
| `<leader>bb` or `` <leader>` `` | switch to last buffer |
| `<leader>bd` / `<leader>bo` | delete this buffer / all other buffers |
| `<A-j>` / `<A-k>` | move line(s) down / up (n, i, v) |
| `j` / `k` | move by *display* line when no count |
| `gco` / `gcO` | add comment line below / above |
| `gcc` / `gc{motion}` | toggle comment (native) |
| `<` / `>` in visual | indent and keep selection |
| `<leader><tab>...` | tab pages (`<tab><tab>` new, `]`/`[` next/prev, `d` close) |

### Surround - `mini.surround` (core, `gs` prefix)

| Key | Action |
| --- | --- |
| `gsa{motion}{char}` | add surround (visual: `gsa{char}`) |
| `gsd{char}` | delete surround |
| `gsr{old}{new}` | replace surround |
| `gsf` / `gsF` | find next / previous surround |
| `gsh` | highlight surround |

### Text objects - `mini.ai` (core)

`a`/`i` + one of: `(` `[` `{` `<` `"` `'` `` ` `` `b` `q`, plus:

| Obj | Meaning |
| --- | --- |
| `f` | function (treesitter) |
| `c` | class (treesitter) |
| `o` | block / conditional / loop |
| `u` / `U` | function call / call without the dotted name |
| `t` | HTML/JSX tag |
| `d` | digits |
| `g` | whole buffer |

`[` / `]` + the same key jumps to the object's edges. See `:h mini.ai`.

## Pickers - snacks.picker

`vim.g.lazyvim_picker = "snacks"` (the `editor.snacks_picker` extra). Telescope is **not** installed.
Inside any picker: `<a-c>` toggle root/cwd, `<a-t>` send to Trouble, `s` / `<a-s>` flash-jump the list, `<C-q>` send all to quickfix.

### Files and buffers

| Key | Picker |
| --- | --- |
| `<leader><space>` / `<leader>ff` | find files (root dir) |
| `<leader>fF` | find files (cwd) |
| `<leader>fg` | git-tracked files |
| `<leader>fr` / `<leader>fR` | recent files / recent in cwd |
| `<leader>fb` / `<leader>fB` | buffers / buffers incl. hidden |
| `<leader>fc` | config files (this nvim dir) |
| `<leader>fp` | projects |
| `<leader>,` | buffers (short alias) |

### Grep and in-file search

| Key | Picker |
| --- | --- |
| `<leader>sb` | **fuzzy-search lines of the current buffer** (Telescope's `current_buffer_fuzzy_find`) |
| `<leader>sB` | live-grep across open buffers |
| `<leader>/` or `<leader>sg` | live-grep (root dir) |
| `<leader>sG` | live-grep (cwd) |
| `<leader>sw` / `<leader>sW` | grep word/selection, root / cwd (n, x) |
| `<leader>sr` | search **and replace** across files (grug-far) |
| `<leader>ss` / `<leader>sS` | LSP document / workspace symbols |
| `<leader>sR` | resume last picker |

### Everything-else pickers

| Key | Picker |
| --- | --- |
| `<leader>sk` | keymaps |
| `<leader>sh` / `<leader>sH` | help / highlights |
| `<leader>sd` / `<leader>sD` | diagnostics (all / buffer) |
| `<leader>sj` / `<leader>sm` / `<leader>sM` | jumps / marks / man pages |
| `<leader>s"` / `<leader>s/` / `<leader>sc` | registers / search history / command history |
| `<leader>sC` / `<leader>sa` | commands / autocmds |
| `<leader>si` | icons |
| `<leader>su` | undo tree |
| `<leader>sp` | plugin specs |
| `<leader>n` | notification history |
| `<leader>uC` | colorschemes |
| `<leader>:` | command history |

## LSP (attached-buffer keys)

| Key | Action |
| --- | --- |
| `gd` / `gD` | definition / declaration |
| `gr` | references |
| `gI` / `gy` | implementation / type definition |
| `K` / `gK` | hover / signature help (`<C-k>` in insert) |
| `<leader>ca` | code action |
| `<leader>cr` / `<leader>cR` | rename symbol / rename file |
| `<leader>cA` | source action |
| `<leader>cc` / `<leader>cC` | run / refresh codelens |
| `<leader>co` | organize imports (when the server offers it) |
| `<leader>cl` | LSP info |
| `<leader>cf` | format now (force) |
| `]]` / `[[`, `<a-n>` / `<a-p>` | next / prev reference of symbol under cursor |
| `<leader>cs` / `<leader>cS` | symbols / references in Trouble |
| `<leader>uh` | toggle inlay hints |

Active servers: `vtsls` (TS/JS), `tailwindcss`, `jsonls`, `yamlls`, `nixd`/`nil`, `marksman` (markdown), `sourcekit` (Swift), `kotlin_lsp` (JetBrains), `lua_ls`.
Servers load per-filetype, so opening a `.ts` file never starts the JVM toolchain.

## Diagnostics, Trouble, quickfix

| Key | Action |
| --- | --- |
| `<leader>cd` | line diagnostics (float) |
| `]d` / `[d` | next / prev diagnostic |
| `]e` / `[e`, `]w` / `[w` | next/prev error, next/prev warning |
| `<leader>xx` / `<leader>xX` | Trouble diagnostics: workspace / current buffer |
| `<leader>xt` / `<leader>xT` | Trouble: TODO comments / TODO+FIX+FIXME |
| `<leader>xL` / `<leader>xQ` | Trouble: location list / quickfix |
| `<leader>xl` / `<leader>xq` | plain location / quickfix window toggle |
| `[q` / `]q` | prev / next quickfix (or Trouble item when open) |
| `]t` / `[t` | next / prev TODO comment |
| `<leader>st` / `<leader>sT` | picker: TODOs / TODO+FIX+FIXME |

## Git

| Key | Action |
| --- | --- |
| `<leader>gg` / `<leader>gG` | lazygit (repo root / cwd) |
| `<leader>gs` / `<leader>gS` | picker: git status / stash |
| `<leader>gd` / `<leader>gD` | picker: diff hunks / diff vs origin |
| `<leader>gl` / `<leader>gL` | git log (root / cwd) |
| `<leader>gf` | history of current file |
| `<leader>gb` | blame current line |
| `<leader>gB` / `<leader>gY` | open / copy the remote URL for the line |
| `<leader>gi` / `<leader>gp` | picker: GitHub issues / PRs |

### Hunks - gitsigns (`<leader>gh`)

| Key | Action |
| --- | --- |
| `]h` / `[h`, `]H` / `[H` | next/prev hunk, last/first hunk |
| `<leader>ghs` / `<leader>ghr` | stage / reset hunk (works in visual) |
| `<leader>ghS` / `<leader>ghR` | stage / reset whole buffer |
| `<leader>ghu` | undo stage hunk |
| `<leader>ghp` | preview hunk inline |
| `<leader>ghb` / `<leader>ghB` | blame line (full) / blame buffer |
| `<leader>ghd` / `<leader>ghD` | diff this / diff this vs `~` |
| `ih` (o/x) | "in hunk" text object |
| `<leader>uG` | toggle git signs |

## AI - sidekick.nvim (`ai.sidekick` extra)

Two features. The CLI-pane half is active; NES needs `:LspCopilotSignIn` first.

### CLI agent pane

| Key | Action |
| --- | --- |
| `<leader>aa` | toggle the agent terminal |
| `<leader>as` | pick which CLI tool to start |
| `<C-.>` | focus / unfocus the agent pane (also from insert / terminal) |
| `<leader>at` | send "this" (word or selection + context) |
| `<leader>af` / `<leader>av` | send whole file / visual selection |
| `<leader>ap` | pick a templated prompt (`{file}`, `{selection}`, `{position}`, ...) |
| `<leader>ad` | detach the session |
| `<a-a>` in a picker | send the picked file(s) to the agent |

Agents run as tmux panes (see `sidekick.lua`), so they outlive nvim and can be attached from a real terminal.
The lualine block shows agent status.

### Next Edit Suggestions (opt-in)

| Key | Action |
| --- | --- |
| `<Tab>` (normal) | jump to / apply the suggested edit |
| `<leader>uN` | toggle NES |

## UI toggles (`<leader>u`)

| Key | Toggles |
| --- | --- |
| `<leader>uf` / `<leader>uF` | autoformat: buffer / global |
| `<leader>us` / `<leader>uw` | spelling / wrap |
| `<leader>ul` / `<leader>uL` | line numbers / relative numbers |
| `<leader>ud` / `<leader>uh` | diagnostics / inlay hints |
| `<leader>uc` | conceal level |
| `<leader>ug` / `<leader>uS` | indent guides / smooth scroll |
| `<leader>ub` | dark / light background |
| `<leader>uT` | treesitter highlight |
| `<leader>uz` / `<leader>uZ` | zen mode / zoom |
| `<leader>uD` / `<leader>ua` | dim inactive / animations |
| `<leader>um` | render-markdown on/off |
| `<leader>uG` | git signs |
| `<leader>ui` / `<leader>uI` | inspect highlights under cursor / inspect TS tree |
| `<leader>ur` | redraw + clear search + diff update |

## Terminal

| Key | Action |
| --- | --- |
| `<C-/>` (or `<C-_>`) | toggle root-dir terminal |
| `<leader>ft` / `<leader>fT` | terminal at root dir / cwd |

## Debug - DAP (`dap.core` extra)

Adapters: `lldb-dap` for Swift (via xcodebuild.nvim), plus whatever the JS extra wires.

| Key | Action |
| --- | --- |
| `<leader>db` / `<leader>dB` | toggle breakpoint / conditional breakpoint |
| `<leader>dc` | start / continue |
| `<leader>da` / `<leader>dl` | run with args / run last |
| `<leader>di` / `<leader>dO` / `<leader>do` | step into / over / out |
| `<leader>dC` / `<leader>dg` | run to cursor / jump to line (no exec) |
| `<leader>dj` / `<leader>dk` | move down / up the stack |
| `<leader>dr` | toggle REPL |
| `<leader>ds` / `<leader>dt` | session info / terminate |
| `<leader>du` | toggle DAP UI |
| `<leader>de` | eval expression (n, x) |
| `<leader>dw` | hover widget |
| `<leader>dpp` / `<leader>dph` | toggle profiler / profiler highlights |

## Markdown

- Rendered in-terminal by **render-markdown.nvim** (no browser, no server). `<leader>um` toggles it.
- `markdown-preview.nvim` is **disabled** here.
- markdownlint is **off** for `markdown` filetype; `marksman` + `prettier` stay on.
- Spell is on: `zg` add word, `zw` mark wrong, `zug` / `zuw` undo. The list is the tracked `spell/en.utf-8.add`.
- `samples/render-markdown-demo.md` exercises every node type - open it to eyeball the theme.
- Inline images (`snacks.image`, Kitty protocol) need a terminal that supports it (Ghostty does).

## Obsidian (`<leader>o`, vault `~/Developer/vault/suchobits` only)

Loads only for markdown under that path, or on demand via the keys / `:Obsidian`.
Rendered by obsidian.nvim's own UI, not render-markdown.

| Key | Action |
| --- | --- |
| `<leader>on` / `<leader>oo` | new note / quick switch |
| `<leader>os` | search vault |
| `<leader>ot` / `<leader>oy` | today's / yesterday's daily note |
| `<leader>ob` / `<leader>ol` | backlinks / links in this note |
| `<leader>oT` | insert template |
| `<leader>op` | paste image (needs `pngpaste`, not installed yet) |
| `<leader>or` / `<leader>ow` | rename note / switch workspace |

Buffer-local inside a vault note:

| Key | Action |
| --- | --- |
| `<CR>` | follow link / toggle checkbox (smart action) |
| `]o` / `[o` | next / previous link |

## Swift / iOS - xcodebuild.nvim (`lua/plugins/swift.lua`, no extra)

| Key | Action |
| --- | --- |
| `<leader>X` | Xcodebuild action picker (everything) |
| `<leader>xb` / `<leader>xr` | build / build & run |
| `<leader>xt` | run tests (visual: run selected tests) |
| `<leader>xT` | run test class |
| `<leader>xe` | toggle test explorer |
| `<leader>xl` | toggle build logs |
| `<leader>xd` / `<leader>xs` | select device / scheme |

Notes: cross-file LSP needs a `.compile` file - run the project's `just lsp` after adding files or changing build settings.
Project files are XcodeGen (`project.yml` -> generated `.xcodeproj`).
On build/test failure Trouble auto-opens on the quickfix list and closes again on success.
Live UI iteration is hot reload (InjectionNext + HotSwiftUI), baked into the `ios-starter` template - the in-editor SwiftUI preview is deliberately not used.
On-device debug needs the one-time passwordless-sudo tunnel install (see README "Swift").

## Kotlin

JetBrains `kotlin-lsp` (`kotlin_lsp` server), not the `lang.kotlin` extra.
Editing only - no build/run loop yet (an Android plugin is planned).
The bundled `intellij-server` EAP build expires ~monthly (bump it in `darwin/kotlin-lsp.nix`).

## Enabled extras (`lazyvim.json`)

| Extra | Gives |
| --- | --- |
| `ai.sidekick` | CLI agent pane + Copilot NES |
| `dap.core` | debugger core + DAP UI |
| `lang.git` | `gitcommit` / `gitignore` / `git-rebase` filetypes |
| `lang.json`, `lang.yaml` | schema-aware editing |
| `lang.markdown` | render-markdown + marksman + markdownlint + prettier |
| `lang.nix` | nixd/nil + formatting |
| `lang.tailwind` | Tailwind / NativeWind class completion |
| `lang.typescript` | vtsls for React + Vite + Expo (`bun`) |
| `editor.snacks_picker` | auto-selected because no fzf/telescope extra is on |

Local specs in `lua/plugins/`: `autosave` `colorscheme` `dashboard` `explorer` `markdown` `obsidian` `sidekick` `tmux-navigator` `kotlin` `swift`.

## Config and plugin management

| Cmd | Purpose |
| --- | --- |
| `:Lazy` (`<leader>l`) | plugin status / install / update / clean / profile |
| `:Lazy update` | bump plugins; writes `lazy-lock.json` (committed - review the diff) |
| `:LazyExtras` | toggle entries in `lazyvim.json` (extras only, not core plugins) |
| `:Mason` | tool installer (formatters, linters, some servers) |
| `:LazyHealth` / `:checkhealth` | diagnose |
| `:LspCopilotSignIn` | needed once before NES does anything |
| `<leader>L` | LazyVim changelog |
| `<leader>qq` | quit all |
