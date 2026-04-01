{ pkgs, ... }:

{
  programs.git = {
    enable = true;

    settings = {
      alias = {
        s = "status";
        d = "diff";
        l = "log --oneline -n 20";
      };

      init.defaultBranch = "main";
      push.autoSetupRemote = true;
      pull.rebase = true;
      credential."https://github.com".helper = "!/usr/bin/env gh auth git-credential";
      credential."https://gist.github.com".helper = "!/usr/bin/env gh auth git-credential";
    };
  };

  programs.delta = {
    enable = true;
    enableGitIntegration = true;
    options = {
      navigate = true;
      light = false;
      side-by-side = true;
    };
  };

  home.packages = with pkgs; [ gh ];
}
