{ lib, ... }:

{
  options.dotfiles = {
    shell = lib.mkOption {
      type = lib.types.enum [ "zsh" "bash" "fish" ];
      default = "zsh";
      description = "Which shell to configure as the default.";
    };

    prompt = lib.mkOption {
      type = lib.types.enum [ "ps1" "starship" "oh-my-posh" ];
      default = "ps1";
      description = "Which prompt engine to use.";
    };

    profile = lib.mkOption {
      type = lib.types.enum [ "desktop" "server" "work" ];
      default = "desktop";
      description = "Which profile to activate (affects Claude agents, MCP servers, extra packages).";
    };
  };
}
