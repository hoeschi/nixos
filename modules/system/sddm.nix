{ config, pkgs, ... }:
{
  services = {
    
    xserver.enable = true;

    displayManager = {

      sddm = {

        enable = true;

        autoNumlock = true;
        theme = "sddm-astronaut-theme";
      };
    };
  };
}