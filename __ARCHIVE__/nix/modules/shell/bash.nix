{ config, lib, ... }:

let
  cfg = config.dotfiles;
  shellCfg = cfg.shellConfig;

  envFile = lib.concatStringsSep "\n"
    (lib.mapAttrsToList (name: value: "export ${name}=${lib.escapeShellArg value}") shellCfg.envVars);
in
{
  config = lib.mkIf (cfg.shell == "bash") {
    programs.bash = {
      enable = true;

      historySize = 10000;
      historyFileSize = 10000;
      historyControl = [ "ignoredups" "ignorespace" "erasedups" ];

      initExtra = ''
        shopt -s histappend
        shopt -s checkwinsize
        shopt -s cdspell
        shopt -s dirspell

        source "$HOME/.config/bash/env.bash"
        source "$HOME/.config/bash/aliases.bash"
        source "$HOME/.config/bash/functions.bash"

        # Source local overrides if present
        [ -f "$HOME/.config/bash/local.bash" ] && source "$HOME/.config/bash/local.bash"
      '';
    };

    xdg.configFile = {
      "bash/env.bash".text = envFile;
      "bash/aliases.bash".text = shellCfg.aliases;
      "bash/functions.bash".text = shellCfg.functions;
    };

    programs.fzf.enableBashIntegration = true;
    programs.zoxide.enableBashIntegration = true;
  };
}
