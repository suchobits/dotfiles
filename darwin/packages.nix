{ pkgs, config, ... }:

let
  user = config.system.primaryUser;
  npmGlobalDir = "/Users/${user}/.npm-global";
in
{
  # Direct-use CLI tools. Some nixpkgs names differ from the Homebrew
  # formula: git-delta -> delta, node -> nodejs, tree-sitter-cli ->
  # tree-sitter. claude-code is omitted: it self-updates to
  # ~/.local/bin/claude, which precedes the Nix profile on $PATH.
  environment.systemPackages = with pkgs; [
    ast-grep
    bat
    beads
    bun
    cocoapods
    codex
    delta
    eza
    fd
    ffmpeg
    fzf
    gh
    glow
    herdr # daily-driver terminal multiplexer (tmux replacement, agent-aware)
    hunk
    imagemagick # snacks.image: non-PNG conversion + resizing (nvim inline images)
    jqp
    just
    just-lsp
    lazygit
    libpq
    librsvg
    maestro # maestro.mobile.dev, not the unrelated same-named brew formula
    mermaid-cli
    neovim
    nil # nvim nix LSP (nil_ls, from the lang.nix extra)
    nixfmt # nvim nix format-on-save (conform); RFC-style Nix formatter
    nodejs
    opencode
    ripgrep
    sesh # smart tmux session manager (prefix + s popup in .tmux.conf)
    starship
    statix # nvim nix linting (nvim-lint)
    stow
    swiftformat # nvim swift format-on-save (conform)
    swiftlint # nvim swift linting (nvim-lint)
    tart
    television # `tv` fuzzy finder: zsh (tv init) + tmux popups + sesh picker
    tmux
    tree-sitter
    uv
    vhs
    watchman
    xcbeautify # formats xcodebuild logs for xcodebuild.nvim
    xcodegen # generate .xcodeproj from project.yml (iOS projects + ios-starter template)
    zoxide
    zulu21
  ];

  # npm-only tools with no nixpkgs or Homebrew package:
  # @earendil-works/pi-coding-agent, and @playwright/cli (the
  # `playwright-cli` binary; nixpkgs' `playwright` is playwright-core,
  # the library only). Installed idempotently on every activation into a
  # per-user prefix.
  #
  # The prefix is not npm's default global prefix: under Nix's nodejs
  # that resolves inside the read-only store, where writes as root
  # succeed but nothing on $PATH can find them. A per-user prefix is the
  # standard nixpkgs fix (NixOS/nixpkgs#3393); its bin/ is added to $PATH
  # in stow/zsh/.config/zsh/env.zsh. The script runs as the user.
  #
  # Install flags:
  #   --allow-scripts   npm 11.16+ warns (npm 12 will block) on dependency
  #     lifecycle scripts not on an allow-list. `npm approve-scripts`
  #     errors EGLOBAL for -g installs (npm/cli#9463), so the packages are
  #     listed inline.
  #   --no-fund --no-audit --loglevel=error   suppress non-error output.
  system.activationScripts.postActivation.text = ''
    echo "installing npm-only CLI tools..." >&2
    sudo --set-home -u ${user} mkdir -p ${npmGlobalDir}
    sudo --set-home -u ${user} env PATH="${pkgs.nodejs}/bin:$PATH" \
      ${pkgs.nodejs}/bin/npm install --prefix ${npmGlobalDir} -g \
        --allow-scripts=@google/genai,esbuild,protobufjs \
        --no-fund --no-audit --loglevel=error \
        @earendil-works/pi-coding-agent @playwright/cli

    # pymobiledevice3: PyPI-only, needed by xcodebuild.nvim for on-device
    # iOS debugging. uv keeps its own venv under ~/.local/share/uv/tools
    # and links the binary into ~/.local/bin; re-run is a fast no-op.
    echo "installing pymobiledevice3..." >&2
    sudo --set-home -u ${user} ${pkgs.uv}/bin/uv tool install --quiet pymobiledevice3
  '';
}
