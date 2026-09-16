{
  description = "NixOS configuration — home-server (Ultron)";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    flake-utils.url = "github:numtide/flake-utils";

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    hermes-agent.url = "github:NousResearch/hermes-agent";
  };

  outputs =
    {
      nixpkgs,
      home-manager,
      flake-utils,
      sops-nix,
      disko,
      hermes-agent,
      ...
    }:
    flake-utils.lib.eachDefaultSystemPassThrough (system:
    let
      pkgs = nixpkgs.legacyPackages.${system};
    in {
      packages.${system} = {
        gen-host-key = pkgs.writeShellApplication {
          name = "gen-host-key";
          runtimeInputs = with pkgs; [ openssh ssh-to-age git ];
          text = builtins.readFile ./gen-host-key.sh;
        };
        install = pkgs.writeShellApplication {
          name = "install";
          runtimeInputs = with pkgs; [ openssh nixos-anywhere git ];
          text = builtins.readFile ./install.sh;
        };
      };

      nixosConfigurations = {
        # $ nix run github:nix-community/nixos-anywhere -- --flake .#home-server root@169.254.138.17
        home-server = nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = { inputs = { inherit hermes-agent; }; };
          modules = [
            # Existing modules
            sops-nix.nixosModules.sops
            disko.nixosModules.disko
            hermes-agent.nixosModules.default
            ./disko.nix
            ./configuration.nix

            # Desktop / display stack
            ./desktop.nix
            ./hermes-desktop.nix

            # Home-manager as a NixOS module
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs    = true;
              home-manager.useUserPackages  = true;
              home-manager.backupFileExtension = "hm-bak";
              # Every desktop user (trevor, mschulte, ...) gets the exact same
              # home-manager profile from home.nix. The account list is the
              # shared desktop-users.nix (also used by configuration.nix), so
              # adding a person to one file adds them everywhere.
              home-manager.users = nixpkgs.lib.genAttrs (builtins.attrNames (import ./desktop-users.nix)) (name: {
                imports = [
                  (import ./home.nix)
                ];
              });
            }
          ];
        };
      };
    });
}
