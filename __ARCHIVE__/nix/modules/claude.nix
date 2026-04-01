{ config, lib, pkgs, self, ... }:

let
  cfg = config.dotfiles;
  isDevProfile = cfg.profile == "desktop" || cfg.profile == "work";

  # Read MCP server configs and merge them
  baseMcp = builtins.fromJSON (builtins.readFile "${self}/config/claude/mcp-servers/base.json");
  desktopMcp = builtins.fromJSON (builtins.readFile "${self}/config/claude/mcp-servers/desktop.json");

  mcpServers =
    if isDevProfile
    then baseMcp.mcpServers // desktopMcp.mcpServers
    else baseMcp.mcpServers;

  claudeJson = builtins.toJSON { inherit mcpServers; };

  # Build agent file entries for home.file
  agentDir = "${self}/config/claude/agents";
  agentFiles = builtins.attrNames (builtins.readDir agentDir);
  agentEntries = builtins.listToAttrs (map (name: {
    name = ".claude/agents/${name}";
    value = { source = "${agentDir}/${name}"; };
  }) agentFiles);
in
{
  home.file = {
    # Claude Code settings
    ".claude/settings.json".source = "${self}/config/claude/settings.json";

    # MCP servers config
    ".claude.json".text = claudeJson;
  } // (lib.optionalAttrs isDevProfile agentEntries);

  # ccstatusline config — copied once on first activation, then left unmanaged
  # so the TUI can freely update it without Nix overwriting changes.
  home.activation.initCcstatusline = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    if [ ! -f "$HOME/.config/ccstatusline/settings.json" ]; then
      $DRY_RUN_CMD mkdir -p "$HOME/.config/ccstatusline"
      $DRY_RUN_CMD cp "${self}/config/claude/ccstatusline/settings.json" "$HOME/.config/ccstatusline/settings.json"
      $DRY_RUN_CMD chmod u+w "$HOME/.config/ccstatusline/settings.json"
    fi
  '';
}
