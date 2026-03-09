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

  dotfiles.profile = "desktop";

  # Desktop defaults (can be overridden in host config)
  dotfiles.shell = "zsh";
  dotfiles.prompt = "oh-my-posh";

  home.packages = with pkgs; [
    lazygit
    lazydocker
    btop
  ];

  programs.home-manager.enable = true;
}
