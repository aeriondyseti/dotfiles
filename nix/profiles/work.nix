{ pkgs, ... }:

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

  dotfiles.profile = "work";

  # Work defaults
  dotfiles.shell = "zsh";
  dotfiles.prompt = "ps1";

  home.packages = with pkgs; [
    lazygit
    lazydocker
  ];

  programs.home-manager.enable = true;
}
