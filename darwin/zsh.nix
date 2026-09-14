{ ... }:

{
  # nix-darwin's default /etc/zshrc runs `compinit` unconditionally on
  # every shell. Its security audit (compaudit) rescans the whole
  # $fpath, which is dozens of directories deep with Nix profiles - real
  # startup cost, every shell. stow/zsh/.config/zsh/init.zsh replaces it
  # with a compinit that only re-audits once a day.
  programs.zsh.enableGlobalCompInit = false;
}
