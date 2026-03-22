{ config, pkgs, ... }:
{
  services.flatpak.enable = true;

  services.flatpak.packages = [
    "com.bambulab.BambuStudio"
  ];
}