{
  description = "Die absolut zusammengeklaute Flake Config von bhoesch";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, ... } @ inputs:
  {

    nixosConfigurations = {

      # Test-Laptop
      echo = nixpkgs.lib.nixosSystem {
        specialArgs = { inherit inputs; };
        modules = [
            ./hosts/echo/configuration.nix
        ];
      };
    };

  };
}
