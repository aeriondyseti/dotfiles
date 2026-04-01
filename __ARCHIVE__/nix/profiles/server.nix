{ ... }:

{
  imports = [
    ../modules/shell/common.nix
    ../modules/shell/zsh.nix
    ../modules/shell/bash.nix
    ../modules/shell/fish.nix
    ../modules/prompt/ps1.nix
    ../modules/prompt/starship.nix
    ../modules/prompt/oh-my-posh.nix
    ../modules/git.nix
    ../modules/cli-tools.nix
    ../modules/claude.nix
  ];

  dotfiles.profile = "server";

  # Server defaults: bash + plain PS1
  dotfiles.shell = "bash";
  dotfiles.prompt = "ps1";

  programs.home-manager.enable = true;
}
