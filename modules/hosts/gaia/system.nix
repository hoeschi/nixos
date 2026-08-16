{
  den,
  inputs,
  ...
}: {
  den.hosts.x86_64-linux.gaia = {
    description = "Main PC (Tower)";
    users.bhoesch.classes = ["homeManager"];
  };

  den.aspects.gaia = {
    includes = [
      den.batteries.hostname

      den.aspects.system.provides.sddm
      den.aspects.gui.provides.plasma
      #den.aspects.gui.provides.hyprland
    ];

    nixos = {
      pkgs,
      config,
      ...
    }: {
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
          experimental-features = ["nix-command" "flakes"];
          auto-optimise-store = true;
        };

        # Garbage collection settings
        gc = {
          automatic = true;
          dates = "weekly";
          options = "--delete-older-than 4d";
        };
      };

      nixpkgs = {
        config.allowUnfree = true;
        overlays = [
          inputs.nur.overlays.default # <-- hinzufügen
        ];
      };

      networking = {
        firewall = {
          trustedInterfaces = ["docker0"];
        };
        # Enable networking
        networkmanager.enable = true;
      };

      environment.sessionVariables = {
        RADV_PERFTEST = "gpl"; # AMD: Shader-Ruckler reduzieren
        PATH = ["$HOME/.local/bin"];
        PULSE_COOKIE = "$HOME/.config/pulse/cookie"; # greift nicht für Steam (eigene libpulse)
        #COPILOT_HOME      = "$HOME/.config/copilot";      # undokumentiert, kann per VSCode-Update wegfallen
        #CLAUDE_CONFIG_DIR = "$HOME/.config/claude";       # undokumentiert; VSCode-Ext. ignoriert sie
      };

      xdg.portal = {
        enable = true;
        extraPortals = with pkgs; [
          xdg-desktop-portal-gtk
        ];
        config.common.default = "*";
      };

      hardware = {
        graphics = {
          enable = true;
          enable32Bit = true;
        };
        graphics.extraPackages = with pkgs; [
          libva-vdpau-driver
          libvdpau-va-gl
        ];
      };

      services = {
        openssh = {
          enable = true;
          listenAddresses = [
            {
              addr = "172.17.0.1";
              port = 22;
            }
          ];
          settings.PasswordAuthentication = false;
        };
        printing = {
          enable = true;
          drivers = with pkgs; [
            epson-escpr
            epson-escpr2 # treiber für meinen Espson WF-26xx
          ];
        };
        avahi = {
          enable = true;
          nssmdns4 = true;
          openFirewall = true;
        };
        ratbagd.enable = true; # mice configuration service(needed for piper)
        input-remapper.enable = true;
        mullvad-vpn.enable = true;
        resolved.enable = true; # enable systemd DNS resolver
      };

      # Enable sound with pipewire.
      services.pulseaudio.enable = false;
      security.rtkit.enable = true;
      services.pipewire = {
        enable = true;
        alsa.enable = true;
        alsa.support32Bit = true;
        pulse.enable = true;
        # If you want to use JACK applications, uncomment this
        jack.enable = true;

        # use the example session manager (no others are packaged yet so this is enabled by default,
        # no need to redefine it in your config for now)
        #media-session.enable = true;
      };

      programs.nix-ld = {
        enable = true;
      };

      virtualisation.docker.enable = true; # to enable the docker deamon

      environment.systemPackages = with pkgs; [
        #home-manager
        nix-output-monitor

        wineWow64Packages.stable
        winetricks
        protontricks

        kicad
        #freecad
        #bambu-studio

        neovim
        wget
        curl
        p7zip
        crosspipe # Pipewire configuration with gui, maintained fork of helvum
        libstrangle
        rustdesk # Remote Zugriff auf Laptop

        python315
        unrar

        _1password-gui

        mullvad-vpn
        mullvad-browser

        whatsapp-electron
        onlyoffice-desktopeditors
        zotero # citation manager
        obsidian # note taking app

        piper # for mouse config

        pavucontrol

        input-remapper

        samba
        cifs-utils
        yt-dlp # xD
        vlc
        libbdplus
        libbluray
        libaacs
        ffmpeg
        mkvtoolnix
        bento4 # for mp4decrypt for Crunchyroll downloads
        #makemkv

        corefonts
        vista-fonts

        gcc
        libgcc
        gnumake
        cmake

        docker
        docker-compose
        lazydocker

        #bottles
        vulkan-tools

        gnutls

        sops
        age
        openssl
      ];

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
