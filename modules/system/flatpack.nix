{ config, pkgs, nix-flatpak, ... }:
{

  services.flatpak.enable = true;
  
  services.flatpak.package = [
    "com.bambulab.BambuStudio"
  ];

}