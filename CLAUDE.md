# dotfiles

Public repo. nix-darwin manages packages, GUI apps, macOS settings, and launchd agents; GNU Stow manages the dotfiles under `stow/`.

## Secrets

No secret values live in any file.
`stow/zsh/.config/zsh/secrets.zsh` holds only variable *names*; values are read from the macOS Keychain at shell startup.
Never write a key, token, or password into a tracked file.

## Docs

- `README.md` - repo overview and design decisions.
- `darwin/README.md`, `stow/README.md` - operational: how to build, switch, add, remove.
- `stow/nvim/.config/nvim/README.md` - a decisions log for the nvim config: why each deviation from stock LazyVim exists, not a mirror of the Lua.
- `stow/nvim/.config/nvim/CHEATSHEET.md` - keys and wiring only.

## One home per caveat

Each recurring gotcha is documented in exactly one place. When it changes, update that place, not the pointers elsewhere:

- kotlin-lsp EAP expiry / monthly `version` bump -> `darwin/kotlin-lsp.nix`
- activation-script naming (nix-darwin#663) -> `darwin/README.md` Notes
- Swift `xc-lsp` / xcode-build-server workflow -> nvim `README.md` Swift section
- obsidian.nvim fork choice -> `stow/nvim/.config/nvim/lua/plugins/obsidian.lua`

Do not reference commit hashes in prose. Do not frame terminal features around Warp - it is no longer used.
