{
  description = "aerion's dotfiles - managed with Nix flakes + home-manager";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, nix-darwin, ... }:
    let
      mkHome = { system, profile ? "desktop" }:
        home-manager.lib.homeManagerConfiguration {
          pkgs = import nixpkgs {
            inherit system;
            config.allowUnfree = true;
          };
          extraSpecialArgs = {
            inherit self;
            dotfilesPath = self;
          };
          modules = [
            ./nix/options.nix
            (
              if builtins.match ".*-linux" system != null
              then ./nix/hosts/linux-x86_64.nix
              else ./nix/hosts/darwin-aarch64.nix
            )
            ./nix/profiles/${profile}.nix
          ];
        };
    in
    {
      homeConfigurations = {
        # Linux desktop (native or WSL)
        "aerion@linux" = mkHome {
          system = "x86_64-linux";
          profile = "desktop";
        };

        "aerion@linux-server" = mkHome {
          system = "x86_64-linux";
          profile = "server";
        };

        "aerion@linux-work" = mkHome {
          system = "x86_64-linux";
          profile = "work";
        };

        # macOS
        "aerion@macos" = mkHome {
          system = "aarch64-darwin";
          profile = "desktop";
        };

        "aerion@macos-work" = mkHome {
          system = "aarch64-darwin";
          profile = "work";
        };
      };
    };
}
