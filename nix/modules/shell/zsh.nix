{ config, lib, pkgs, ... }:

let
  cfg = config.dotfiles;
  shellCfg = cfg.shellConfig;

  envFile = lib.concatStringsSep "\n"
    (lib.mapAttrsToList (name: value: "export ${name}=${lib.escapeShellArg value}") shellCfg.envVars);
in
{
  config = lib.mkIf (cfg.shell == "zsh") {
    programs.zsh = {
      enable = true;
      autosuggestion.enable = true;
      syntaxHighlighting.enable = true;

      history = {
        size = 10000;
        save = 10000;
        share = true;
        ignoreDups = true;
        ignoreAllDups = true;
        append = true;
      };

      oh-my-zsh = {
        enable = true;
        theme = ""; # oh-my-posh handles the prompt
        plugins = [
          "1password"
          "aliases"
          "brew"
          "catimg"
          "chezmoi"
          "colored-man-pages"
          "command-not-found"
          "cp"
          "dnote"
          "docker"
          "docker-compose"
          "dotenv"
          "extract"
          "fzf"
          "gh"
          "git"
          "git-commit"
          "git-extras"
          "gitignore"
          "kitty"
          "mise"
          "nmap"
          "ssh"
          "sudo"
          "uv"
        ] ++ lib.optionals (cfg.profile == "work") [ "jira" ];
      };

      initContent = ''
        source "$HOME/.config/zsh/env.zsh"
        source "$HOME/.config/zsh/aliases.zsh"
        source "$HOME/.config/zsh/functions.zsh"

        # Source local overrides if present
        [ -f "$HOME/.config/zsh/local.zsh" ] && source "$HOME/.config/zsh/local.zsh"
      '';
    };

    xdg.configFile = {
      "zsh/env.zsh".text = envFile;
      "zsh/aliases.zsh".text = shellCfg.aliases;
      "zsh/functions.zsh".text = shellCfg.functions;
    };

    programs.fzf.enableZshIntegration = true;
    programs.zoxide.enableZshIntegration = true;

    home.packages = with pkgs; [
      zsh-autosuggestions
      zsh-syntax-highlighting
    ];
  };
}
