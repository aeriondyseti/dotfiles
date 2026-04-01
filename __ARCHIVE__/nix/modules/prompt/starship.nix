{ config, lib, self, ... }:

let
  cfg = config.dotfiles;
in
{
  config = lib.mkIf (cfg.prompt == "starship") {
    programs.starship = {
      enable = true;
      enableBashIntegration = cfg.shell == "bash";
      enableZshIntegration = cfg.shell == "zsh";
      enableFishIntegration = cfg.shell == "fish";
    };

    xdg.configFile."starship.toml".source = "${self}/config/starship.toml";
  };
}
