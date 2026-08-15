{ config, pkgs, ... }:
{
  services = {

    xserver.enable = true;

    displayManager = {

      sddm = {

        enable = true;

        autoNumlock = true;
        #package = pkgs.kdePackages.sddm;
        #theme = "sddm-astronaut-theme";
      };
    };
  };
}