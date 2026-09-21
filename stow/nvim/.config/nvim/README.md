# nvim

[LazyVim](https://www.lazyvim.org/) as the base, with a thin layer of local overrides on top.
Stowed to `~/.config/nvim/` by the `nvim` package (see [stow/README.md](../../../README.md)).

This file is a decisions log: what deviates from stock LazyVim and why.
It is not a mirror of the config - read the Lua for the current state.

## Layout

| Path | Contents |
| --- | --- |
| `init.lua`, `lua/config/` | LazyVim bootstrap; local additions in `keymaps.lua` (`jj`/`jk` -> `<Esc>`, `<leader>bb` rebound to the snacks buffer picker - see File explorer and pickers), `options.lua` + `autocmds.lua` (project spell dictionary, see Markdown) |
| `lazyvim.json` | Enabled LazyVim extras - the declarative "these are the batteries I want" list |
| `lua/plugins/*.lua` | Local plugin specs: overrides on top of extras, plus tooling that has no extra |
| `vira/` | Vira Carbon colorscheme, vendored (see below) |
| `lazy-lock.json` | Pinned plugin commits; committed so installs are reproducible |

## Base and extras

LazyVim gives a maintained, filetype-scoped plugin baseline so a single config can cover every stack without `NVIM_APPNAME` aliasing.
Heavy language servers load on their filetype, so opening a TypeScript file never starts the JVM toolchain.

Extras are enabled in `lazyvim.json` rather than copied into `lua/plugins/`.
A local file is added only when an extra needs a real change - not to restate what the extra already does.

| Extra | Why |
| --- | --- |
| `ai.sidekick` | [sidekick.nvim](https://github.com/folke/sidekick.nvim) - terminal pane to watch and drive CLI coding agents; Copilot Next Edit Suggestions come with it but are opt-in via `:LspCopilotSignIn` |
| `lang.typescript` | vtsls for the web stack: React + Vite + Expo, package manager is `bun` |
| `lang.tailwind` | Tailwind / NativeWind class completion in the same web stack |
| `lang.markdown` | render-markdown.nvim + marksman + markdownlint + prettier |
| `lang.json`, `lang.yaml` | schema-aware editing for config-heavy repos |
| `lang.git` | `gitcommit` / `gitignore` / `git-rebase` filetypes |

Deliberately not enabled:

- `lang.kotlin` - it wires the unmaintained fwcd server via Mason; see Kotlin below.
- No Swift extra exists; see Swift below.

## Local overrides (`lua/plugins/`)

| File | What it changes |
| --- | --- |
| `autosave.lua` | `okuuva/auto-save.nvim` - writes changed buffers after a typing pause, since `<C-s>` (LazyVim's save) is eaten by the tmux prefix |
| `colorscheme.lua` | Loads the vendored Vira Carbon and hands its name to LazyVim |
| `dashboard.lua` | Restores snacks.nvim's own `NEOVIM` banner over LazyVim's `LAZYVIM` one |
| `explorer.lua` | Enables dotfiles in snacks explorer/picker while excluding .git and OS artifacts |
| `markdown.lua` | Drops markdownlint for `markdown`, keeps `markdown-preview.nvim` as an on-demand browser view, tunes render-markdown headings/checkboxes (see Markdown below) |
| `obsidian.lua` | `obsidian.nvim` scoped to the `suchobits` vault, rendered by its own `ui` (see Obsidian below) |
| `sidekick.lua` | Routes agent sessions through `tmux` (from `stow/tmux`) so they outlive nvim |
| `tmux-navigator.lua` | nvim half of `vim-tmux-navigator` so `<C-hjkl>` crosses the nvim-split / tmux-pane boundary (tmux half is in `stow/tmux`) |
| `kotlin.lua` | Configures the JetBrains `kotlin_lsp` server instead of fwcd |
| `swift.lua` | `sourcekit` LSP + `xcodebuild.nvim` + Swift format/lint, new-file templates (`templates/swift/`), autoread timer (see Swift below) |

## Colorscheme

Vira Carbon lives in `vira/` and is loaded by lazy.nvim via `dir =`, not from a Git repo.
It is developed here and has no upstream, so a local directory plugin is simpler than a throwaway repo or a submodule.
LazyVim owns the `:colorscheme` call, so `colorscheme.lua` passes it the name rather than calling `vim.cmd.colorscheme` directly.

Known gotcha: this theme has to define the markdown highlight groups `render-markdown.nvim` uses - keep them in sync when the plugin adds groups.

## Markdown

Default rendering is in-terminal: `render-markdown.nvim` (from `lang.markdown`) is pure text, virtual text, and highlights, with no terminal graphics protocol and no server.

`markdown-preview.nvim`, also bundled by that extra, is kept for the cases the terminal renderer can't cover (live-scrolling browser view, mermaid, MathJax, print-accurate layout).
It runs a local Node server, so it launches only on demand via `<leader>cp` (`:MarkdownPreviewToggle`); nothing starts on filetype.
It is left exactly as `lang.markdown` ships it - `markdown.lua` no longer disables it.
First run builds the plugin (`mkdp#util#install`, needs `npm` on `$PATH`); `:Lazy build markdown-preview.nvim` retries if that fails.
Inline *image* rendering is a separate concern handled by `snacks.image` (enabled in `swift.lua`): it uses the Kitty graphics protocol, so images need a terminal that supports it (Ghostty does).
`swift.lua` sets `image.doc.inline = false`, so generated diagrams (mermaid, via `mermaid-cli`) render in a popup while the cursor is on the fence rather than as buffer text that hides on cursor-over and shifts the source; `<leader>cp` is the full-document view.

The `lang.markdown` extra sets `heading.icons = {}`, which strips the per-level circle glyphs `render-markdown.nvim` shows by default and makes headings look unrendered.
`markdown.lua` puts the default icon set back so heading level reads at a glance.
The same extra ships `checkbox.enabled = false`; `markdown.lua` turns it back on so `[ ]` / `[x]` render as glyphs.

markdownlint-cli2 (wired through nvim-lint by the same extra) is switched off for `markdown` in `markdown.lua`.
Its rules are published-doc house style and only add noise to personal notes; `marksman` (LSP) and `prettier` (format) stay on.

LazyVim keeps `spell` on for `markdown`, so jargon shows as misspelled.
The project dictionary is `spell/en.utf-8.add` (stowed to `~/.config/nvim/spell/`); `zg` over a word in normal mode appends to it, `zw` marks one wrong, `zug` / `zuw` undo.
Vim compiles it to `spell/en.utf-8.add.spl` on first use - that binary is gitignored, the `.add` file is the source of truth.

`samples/render-markdown-demo.md` exercises every node type the renderer touches - open it and toggle `<leader>um` for a quick visual check.

## Obsidian

`obsidian.lua` wires [obsidian-nvim/obsidian.nvim](https://github.com/obsidian-nvim/obsidian.nvim), the maintained community fork.

One vault: `suchobits` at `~/Developer/vault/suchobits`.
The plugin lazy-loads on markdown files under that path, plus on demand for `:Obsidian` and the `<leader>o` keymaps, so markdown elsewhere in the config never activates it.

Rendering inside the vault is obsidian.nvim's own `ui` module, not `render-markdown.nvim`.
`obsidian.lua` extends the `render-markdown.nvim` spec with an `ignore` predicate that skips vault buffers (checked on attach, so no autocmd race), and re-links obsidian's `ui.hl_groups` from their hard-coded Material palette to Vira Carbon's `@markup.*` groups.

`ripgrep` (search and completion) is already in `darwin/packages.nix`.
`:Obsidian paste_img` (`<leader>op`) additionally needs `pngpaste`, which is not installed - add it to `darwin/packages.nix` if image pasting is wanted.

## Kotlin

Uses JetBrains' [kotlin-lsp](https://github.com/Kotlin/kotlin-lsp), configured as a `kotlin_lsp` server in `kotlin.lua` (`cmd`, `filetypes`, and root markers spelled out, since the pinned nvim-lspconfig has no runtime config for it yet).
fwcd/kotlin-language-server is no longer maintained, so the maintained server is worth taking even in its current Alpha state.
It bundles its own JBR, so no JDK wiring is needed on the nvim side.
Android Gradle Plugin support is experimental upstream - expect false diagnostics in Android app modules until it matures.

Binary install is a pinned download in [`darwin/kotlin-lsp.nix`](../../../../darwin/kotlin-lsp.nix): it fetches the JetBrains CDN bundle, checksum-verifies it, unpacks it under `~/.local/share/kotlin-lsp/`, and symlinks `~/.local/bin/kotlin-lsp` (on `$PATH`) at `bin/intellij-server`.
`kotlin-lsp` is not in nixpkgs (community flakes only as of mid-2026), and `darwin/homebrew.nix` is casks-only, so a `postActivation` script is the least-invasive fit.

Caveat: the bundled `intellij-server` EAP build expires ~monthly and needs a `version` bump in [`darwin/kotlin-lsp.nix`](../../../../darwin/kotlin-lsp.nix) (details there).

### Gradle build/run

`gradle.lua` wires build/test/run for Gradle Kotlin projects (Spring Boot today) - v1 of a Kotlin equivalent to `swift.lua`'s xcodebuild.nvim role.
Code lives in the private `dotfiles-gradle` repo, symlinked to `<config>/gradle` the same way `vira/` is (kept private while it stabilizes, per the Android section below).

- `<leader>kb` / `<leader>kt` / `<leader>kc` - build / test / clean via `./gradlew`. Output is parsed into the quickfix list (kotlinc's `e: file://<path>:<line>:<col> <message>` format); Trouble auto-opens on failure and closes on success, same pattern as Swift.
- `<leader>kl` - toggle a scratch buffer with the last task's full raw output.
- `<leader>kr` - run (`bootRun` if `build.gradle(.kts)` has the Spring Boot plugin, else `run`; prompts to confirm/override) in a `snacks.terminal` split, since a running server wants a live, interactive view rather than structured errors.

## Swift / iOS / macOS

`swift.lua` wires:

- `sourcekit` LSP - `cmd = { "xcrun", "sourcekit-lsp" }`; the nvim-lspconfig preset supplies filetypes and root markers. Cross-file resolution needs a `.compile` file: `xcode-build-server`'s `config` (kind: xcode) can't read Xcode 26 build logs, so `xc-lsp` (`stow/zsh/.config/zsh/functions.zsh`) does a clean build piped through `xcode-build-server parse -a` (kind: manual) instead. xcodebuild.nvim's `xcode_build_server` integration is disabled because it would run the broken `config`. Re-run `xc-lsp` after adding files, deps, or changing build settings, then `:LspRestart`. `buildServer.json` and `.compile` are globally gitignored (`stow/git`).
- [xcodebuild.nvim](https://github.com/wojciech-kulik/xcodebuild.nvim) for build / run / test / simulator / test-explorer, keys under `<leader>x` and the picker on `<leader>X`. Uses the snacks picker, `xcbeautify` for logs, and Xcode 26's bundled `lldb-dap` (no codelldb). DAP comes from the `dap.core` extra.
- Project files are managed with **XcodeGen** (`xcodegen` in `darwin/packages.nix`): the `.xcodeproj` is generated from a committed `project.yml` and gitignored, so adding a file is just dropping it in the target's source dir + `xcodegen generate`. xcodebuild.nvim's own file-tree sync (needs `xcp`, Homebrew-only) stays off, and the `nvim_tree` / `neo_tree` / `oil_nvim` integrations are disabled so none hijacks `nvim .` from the snacks explorer + dashboard.
- `conform` -> `swiftformat`, `nvim-lint` -> `swiftlint` (both from `darwin/packages.nix`).
- On-device debugging via `pymobiledevice`. `pymobiledevice3` is PyPI-only, installed as a `uv tool` by `darwin/packages.nix`'s activation script. iOS 17+ needs a passwordless-sudo tunnel: run the plugin's one-time installer, which copies `tools/remote_debugger` to a root-owned dir and adds a single `NOPASSWD` sudoers line -
  ```sh
  DEST="$HOME/Library/xcodebuild.nvim" && \
    SOURCE="$HOME/.local/share/nvim/lazy/xcodebuild.nvim/tools/remote_debugger" && \
    ME="$(whoami)" && \
    sudo install -d -m 755 -o root "$DEST" && \
    sudo install -m 755 -o root "$SOURCE" "$DEST" && \
    sudo bash -c "echo \"$ME ALL = (ALL) NOPASSWD: $DEST/remote_debugger\" >> /etc/sudoers"
  ```
- New empty `*.swift` files get an Xcode-style header from `templates/swift/<kind>.txt` (`kind` from the filename suffix - `FooView.swift` -> `view.txt` - else `empty.txt`); placeholders `{filename}` / `{group}` / `{author}` / `{date}` / `{cursor}`.
- A 2s `checktime` timer reloads files changed by Xcode / the simulator build (LazyVim's `FocusGained` reload does not fire under tmux).
- On build / test failure, Trouble auto-opens on the quickfix list (errors already land there); it closes again on success.
- `snacks.image` is enabled for inline images: `:XcodebuildFailingSnapshots` diffs, asset-catalog previews, markdown images (Ghostty only).

`xcode-build-server` runs under macOS's system `python3` (pinned in `darwin/xcode-build-server.nix`), not whatever `python3` is first on `$PATH`.

In-nvim pbxproj editing (`xcp`) is skipped - XcodeGen handles project files. Xcode stays for signing, capabilities, and Instruments.

Live UI iteration is **hot reload** ([InjectionNext] + `HotSwiftUI`), baked into the [`ios-starter`](https://github.com/suchobits/ios-starter) template (DEBUG-only SPM deps + `-Xlinker -interposable` + `@ObserveInjection` / `.enableInjection()`); the only per-machine step is installing `InjectionNext.app`.
xcodebuild.nvim's in-editor SwiftUI preview (`:XcodebuildPreviewGenerateAndShow`) is deliberately not used - its off-window `sizeThatFits` snapshot clips non-full-screen views, and the plugin author recommends hot reload instead.

[InjectionNext]: https://github.com/johnno1962/InjectionNext

## Android

`gradle/lua/gradle/android.lua` (in `dotfiles-gradle`, same plugin as the Gradle core above) layers install/launch/logcat on top of it:

- `<leader>ar` - detects the Android app module (the one directory under the project with `src/main/AndroidManifest.xml`, preferring one named `app`; prompts if there's more than one candidate), builds it via the shared `gradle.task()` path (`:app:assembleDebug` - same quickfix/Trouble treatment as any other Gradle build), then installs and launches it with the `android` CLI (`android run --apks=...`), which auto-detects the launcher activity from the APK - no manifest parsing needed here.
- `<leader>al` - toggles a live `adb logcat` filtered to the app's PID, in a `snacks.terminal` split.
- `<leader>ad` - (re-)selects the target device: uses the one connected `adb` device silently, prompts among several, or offers to boot an AVD (`android emulator start`, which blocks until ready) if none are connected.

Kotlin LSP already covers editing; this is only the build/run/device loop.

## File explorer and pickers

`snacks.nvim` hides dotfiles by default, which makes a dotfile repo's `stow/*/` dirs look empty (everything under them sits in `.config/`).
`explorer.lua` sets `hidden = true` for the `explorer` and `files` sources, still excluding `.git` and OS files and still hiding gitignored files (`ignored = false`, so the `H` / `I` toggles behave).

LazyVim's default `<leader>bb` runs `:e #`, which reopens the alternate file by path regardless of whether `<leader>bd` deleted its buffer - the "deleted" buffer comes back.
`keymaps.lua` rebinds it to `Snacks.picker.buffers()`, which only lists buffers still on the buffer list.

## One config, many stacks

No `NVIM_APPNAME` aliasing.
LazyVim's filetype scoping keeps the stacks from colliding, and per-project tuning goes through `.neoconf.json` (already present) or a project-local `.nvim.lua` exrc.
Neovim is the editor for all of web, Spring Boot Kotlin, Android, and iOS; it does not replace Xcode or Android Studio for build tooling, device management, and platform UI work.

## Updating

`lazy-lock.json` is committed.
`:Lazy update` bumps it; review the diff before committing.
`:LazyExtras` toggles entries in `lazyvim.json`; edit that file directly for a reviewable change.
