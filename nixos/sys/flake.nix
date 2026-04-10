{
  description = "NixOS configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
  };

  outputs = { self, nixpkgs, nixpkgs-unstable, nixos-hardware, ... }:
  {
    nixosConfigurations.euclid = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ./configuration.nix
        {
          # Set the path to the Flake for reproducibility
          nix.registry.nixpkgs.flake = nixpkgs;
          # Optionally, disable channels
          nix.nixPath = [ "nixpkgs=${nixpkgs.outPath}" ];
        }
        nixos-hardware.nixosModules.lenovo-thinkpad-p16s-amd-gen4
      ];
      specialArgs = {
        unstable = import nixpkgs-unstable {
          system = "x86_64-linux";
          config.allowUnfree = true;
        };
      };
    };
  };
}
