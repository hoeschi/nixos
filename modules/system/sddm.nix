{ config, pkgs, ... }:
{
  services = {
    
    xserver = {
      enable = true;
      xkb = {
          layout = "de";
          variant = "";
        };
    };

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