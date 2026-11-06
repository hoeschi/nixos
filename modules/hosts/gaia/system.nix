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
      den.aspects.gui.provides.stylix

      den.aspects.audio
    ];

    nixos = {
      pkgs,
      config,
      ...
    }: {
      imports = [
        ./_hardware.nix
      ];

      theming = {
        colorSource = "wallpaper"; # wallpaper or stylix
      };

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

        # Garbage collection übernimmt programs.nh.clean
        gc.automatic = false;
      };

      # Behält immer die letzten 5 Generationen, auch wenn sie älter als 7 Tage sind
      programs.nh = {
        enable = true;
        clean = {
          enable = true;
          dates = "weekly";
          extraArgs = "--keep 5 --keep-since 7d";
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

      # Standard-Apps nach Dateityp (MIME-Typ, nicht Dateiendung).
      # Landet in /etc/xdg/mimeapps.list. Einträge in der User-Datei
      # ~/.config/mimeapps.list haben Vorrang, falls dort gesetzt.
      # MIME-Typ einer Datei prüfen: xdg-mime query filetype <datei>
      xdg.mime.defaultApplications = {
        # Ordner aus anderen Apps (z.B. Prism "Mods-Ordner öffnen")
        # in Nemo statt in VS Code öffnen
        "inode/directory" = "nemo.desktop";
        "application/x-gnome-saved-search" = "nemo.desktop";

        # Text- und Konfigurationsdateien in Kate öffnen
        "text/plain" = "org.kde.kate.desktop"; # .txt .conf .cfg .ini (auch .ino, CMakeLists.txt)
        "text/x-log" = "org.kde.kate.desktop"; # .log
        "text/markdown" = "org.kde.kate.desktop"; # .md

        # Programmier-Dateien in VS Code öffnen
        "text/x-python" = "code.desktop"; # .py
        "application/x-ipynb+json" = "code.desktop"; # .ipynb
        "text/x-nix" = "code.desktop"; # .nix
        "text/x-shellscript" = "code.desktop"; # .sh
        "text/x-csrc" = "code.desktop"; # .c
        "text/x-chdr" = "code.desktop"; # .h
        "text/x-c++src" = "code.desktop"; # .cpp
        "text/x-c++hdr" = "code.desktop"; # .hpp
        "text/x-cmake" = "code.desktop"; # .cmake
        "text/x-makefile" = "code.desktop"; # Makefile .mk
        "text/rust" = "code.desktop"; # .rs
        "text/x-go" = "code.desktop"; # .go
        "text/x-java" = "code.desktop"; # .java
        "text/x-lua" = "code.desktop"; # .lua
        "text/javascript" = "code.desktop"; # .js
        "text/vnd.trolltech.linguist" = "code.desktop"; # .ts (wird als Qt-Übersetzung erkannt)
        "text/css" = "code.desktop"; # .css
        "application/json" = "code.desktop"; # .json
        "application/yaml" = "code.desktop"; # .yaml .yml
        "application/toml" = "code.desktop"; # .toml
        "application/xml" = "code.desktop"; # .xml
      };

      hardware = {
        graphics = {
          enable = true;
          enable32Bit = true;
        };
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

        udisks2.enable = true;

        dbus.packages = [pkgs.kdePackages.kio];

        gvfs.enable = true; # SFTP/SMB
        gnome.gnome-keyring.enable = true; # Passwörter merken
      };

      # Enable sound with pipewire.
      #services.pulseaudio.enable = false;
      #security.rtkit.enable = true;
      #services.pipewire = {
      #  enable = true;
      #  alsa.enable = true;
      #  alsa.support32Bit = true;
      #  pulse.enable = true;
      #  # If you want to use JACK applications, uncomment this
      #  jack.enable = true;
      #
      #  # use the example session manager (no others are packaged yet so this is enabled by default,
      #  # no need to redefine it in your config for now)
      #  #media-session.enable = true;
      #};

      programs = {
        nix-ld = {
          enable = true;
        };

        wireshark = {
          enable = true;
          package = pkgs.wireshark; # GUI; Default wäre wireshark-cli
        };
      };

      virtualisation.docker.enable = true; # to enable the docker deamon

      environment.systemPackages = with pkgs; [
        #home-manager
        nix-output-monitor

        kdePackages.dolphin
        kdePackages.ark
        kdePackages.kio-extras
        kdePackages.kded

        nemo-with-extensions

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
        #onlyoffice-desktopeditors
        #zotero # citation manager
        obsidian # note taking app

        piper # for mouse config

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

        btop

        staruml
        #gaphorixos

        #alsa-utils
        #pwvucontrol
        #qpwgraph
        pavucontrol

        jq
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
