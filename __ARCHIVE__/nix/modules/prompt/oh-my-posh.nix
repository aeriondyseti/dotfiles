{ config, lib, self, ... }:

let
  cfg = config.dotfiles;
in
{
  config = lib.mkIf (cfg.prompt == "oh-my-posh") {
    programs.oh-my-posh = {
      enable = true;
      enableBashIntegration = cfg.shell == "bash";
      enableZshIntegration = cfg.shell == "zsh";
      enableFishIntegration = cfg.shell == "fish";
    };

    xdg.configFile."oh-my-posh/config.toml".source = "${self}/config/oh-my-posh.toml";
  };
}
