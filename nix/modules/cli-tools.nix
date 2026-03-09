{ pkgs, ... }:

{
  home.packages = with pkgs; [
    bat
    eza
    fd
    ripgrep
    fzf
    jq
    zoxide
    delta
  ];

  programs.bat = {
    enable = true;
    config = {
      theme = "Dracula";
      pager = "less -FR";
    };
  };

  programs.fzf = {
    enable = true;
    defaultOptions = [ "--height 40%" "--layout=reverse" "--border" "--inline-info" ];
    defaultCommand = "fd --type f --hidden --exclude .git";
  };

  programs.zoxide = {
    enable = true;
  };
}
