{ ... }:

{
  home = {
    username = "aerion";
    homeDirectory = "/home/aerion";
    stateVersion = "24.11";
  };

  targets.genericLinux.enable = true;

  home.sessionVariables = {
    BROWSER = "xdg-open";
  };
}
