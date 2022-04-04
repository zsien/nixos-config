{
  description = "My NixOS configurations";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-master.url = "github:nixos/nixpkgs/master";
    nixos-hardware.url = "github:nixos/nixos-hardware";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nur.url = github:nix-community/NUR;
    sops-nix.url = github:Mic92/sops-nix;
  };

  outputs = { self, nixpkgs, nixpkgs-master, nixos-hardware, home-manager, nur, sops-nix }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;

        config.allowUnfree = true;

        overlays = [
          (final: prev: {
            master = import nixpkgs-master {
              inherit system;

              config.allowUnfree = true;
            };
          })
          (import ./overlays/neovim.nix)
          nur.overlay
        ];
      };
      mkNixOS = name: {user, home-manager, sops-nix }: nixpkgs.lib.nixosSystem {
        inherit system pkgs;

        specialArgs = {
          inherit nixos-hardware;
        };

        modules = [
          ({pkgs, ...}: {
            nix = {
              package = pkgs.nixUnstable;
              extraOptions = ''
                experimental-features = nix-command flakes
              '';
            };
          })

          ./modules/root-dir/.
          ./modules/sops/.
          ./nixos/${name}/.
          ./users/${user}/nixos.nix

          home-manager.nixosModules.home-manager {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.${user} = {
              imports = [
                ./modules/root-dir/.
                ./users/${user}/home-manager.nix
              ];
            };
          }

          sops-nix.nixosModules.sops
        ];
      };
    in {
      nixosConfigurations = {
        zsien-ut = mkNixOS "zsien-ut" {
          user = "zsien";
          inherit home-manager sops-nix;
        };
      };
    };
}
