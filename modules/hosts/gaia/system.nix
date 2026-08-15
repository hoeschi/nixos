{den, inputs, ...}: 
{
  den.hosts.x86_64-linux.gaia = {
    description = "Main PC (Tower)";
    users.bhoesch.classes = ["homeManager"];
  };

  den.aspects.gaia = {

    includes = [ 
      den.batteries.hostname
      
    ];

    nixos = {pkgs, config, ...}: {

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
    
      nixpkgs.overlays = [
        inputs.nur.overlays.default   # <-- hinzufügen
      ];

      networking = {
        firewall = {
          trustedInterfaces = [ "docker0" ];
        };
        # Enable networking
        networkmanager.enable = true;
      };

      
      environment.sessionVariables = {
        RADV_PERFTEST     = "gpl";                        # AMD: Shader-Ruckler reduzieren
        PATH              = [ "$HOME/.local/bin" ];
        PULSE_COOKIE      = "$HOME/.config/pulse/cookie"; # greift nicht für Steam (eigene libpulse)
        COPILOT_HOME      = "$HOME/.config/copilot";      # undokumentiert, kann per VSCode-Update wegfallen
        CLAUDE_CONFIG_DIR = "$HOME/.config/claude";       # undokumentiert; VSCode-Ext. ignoriert sie
    };


      services = {
        openssh = {
          enable = true;
          listenAddresses = [{ addr = "172.17.0.1"; port = 22; }];
          #settings.PasswordAuthentication = false;
        };
      };



      # This value determines the NixOS release from which the default
      # settings for stateful data, like file locations and database versions
      # on your system were taken. It‘s perfectly fine and recommended to leave
      # this value at the release version of the first install of this system.
      # Before changing this value read the documentation for this option
      # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
      system.stateVersion = "25.11"; # Did you read the comment?
    };
  };
}