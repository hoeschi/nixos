{
  description = "Die absolut zusammengeklaute Flake Config von bhoesch";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nur = {
      url = "github:nix-community/nur";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    stylix = {
      url = "github:nix-community/stylix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-flatpak = {
      url = "github:gmodena/nix-flatpak/?ref=latest";
      #inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-claude-code = {
      url = "github:ryoppippi/nix-claude-code";
      #inputs.nixpkgs.follows = "nixpkgs";
    };

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    esp-dev.url = "github:mirrexagon/nixpkgs-esp-dev";

  };

  outputs = { self, nixpkgs, home-manager, nix-flatpak, stylix, nix-claude-code, sops-nix, esp-dev,... } @ inputs:
  let
    system = "x86_64-linux";
  in {

    nixosConfigurations = {

      # Test-Laptop
      echo = nixpkgs.lib.nixosSystem {
        specialArgs = { inherit inputs; };
        modules = [
            ./hosts/echo/configuration.nix
            sops-nix.nixosModules.sops
        ];
      };

      # Main-Desktop
      gaia = nixpkgs.lib.nixosSystem {
        specialArgs = { inherit inputs; };
        modules = [
            ./hosts/gaia/configuration.nix
            sops-nix.nixosModules.sops
        ];
      };
    };

    devShells.${system} = {
      esp32 = esp-dev.devShells.${system}.esp-idf-full;
    };

  };
  
}
