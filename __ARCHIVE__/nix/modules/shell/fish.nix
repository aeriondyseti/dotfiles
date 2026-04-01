{ config, lib, ... }:

let
  cfg = config.dotfiles;
  shellCfg = cfg.shellConfig;

  # Convert bash-style aliases to fish abbreviations where possible.
  # Complex aliases (with pipes, &&, etc.) become shell functions instead.
  isSimpleAlias = v: builtins.match ".*[|&;$].*" v == null;

  simpleAliases = lib.filterAttrs (_: v: isSimpleAlias v) shellCfg.aliases;
  complexAliases = lib.filterAttrs (_: v: !isSimpleAlias v) shellCfg.aliases;

  # Generate fish functions for complex aliases
  complexAliasFunctions = lib.concatStringsSep "\n" (
    lib.mapAttrsToList (name: value: ''
      function ${name} --description '${name} alias'
        ${value}
      end
    '') complexAliases
  );
in
{
  config = lib.mkIf (cfg.shell == "fish") {
    programs.fish = {
      enable = true;

      shellAbbrs = simpleAliases;

      shellInit = ''
        # Environment variables
        ${lib.concatStringsSep "\n" (
          lib.mapAttrsToList (k: v: "set -gx ${k} ${lib.escapeShellArg v}") shellCfg.envVars
        )}
      '';

      interactiveShellInit = ''
        # Complex aliases as functions
        ${complexAliasFunctions}

        # Source local overrides if present
        if test -f "$HOME/.config/fish/local.fish"
          source "$HOME/.config/fish/local.fish"
        end
      '';

      # Note: bash/zsh functions from common.nix won't work directly in fish.
      # The most-used ones should be rewritten as fish functions over time.
      # For now, complex shell functions are available via `bash -c '...'`.
    };

    programs.fzf.enableFishIntegration = true;
    programs.zoxide.enableFishIntegration = true;
  };
}
