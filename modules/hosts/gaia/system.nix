{den, ...}: 
{
  den.hosts.x86_64-linux.gaia = {
    description = "Main PC (Tower)";
    domain = "";
    users.bhoesch.classes = ["homeManager"];
  };

den.ascpects.gaia = {

  includes = [ 
    den.batteries.hostname
    den.provides.hostname
    
    
    ];

  };

  nixos = {pkgs, ...}: {

    imports = [
      ./_hardware.nix
    ];
  
    # Bootloader.
    boot.loader = {
      systemd-boot.enable = false;
      efi.canTouchEfiVariables = true;

      grub = {
        enable = true;
        efiSupport = true;
        device = "nodev";

        useOSProber = true;
      };
    };

    nix = {
      channel.enable = false;

      settings = {
          experimental-features = [ "nix-command" "flakes" ];
          auto-optimise-store = true;
      };

      # Garbage collection settings
      gc = {
        automatic = true;
        dates = "weekly";
        options = "--delete-older-than 4d";
      };
    };
  

    networking = {
      firewall = {
        trustedInterfaces = [ "docker0" ];
      };
      # Enable networking
      networkmanager.enable = true;
    };


    
  };

}