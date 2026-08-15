# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ inputs, config, pkgs, ... }:

{

    nixpkgs.overlays = [
        inputs.nur.overlays.default   # <-- hinzufügen
        #inputs.nix-claude-code.overlays.default
    ];


  imports =
    [ # Include the results of the hardware scan.
        ./hardware-configuration.nix
        inputs.home-manager.nixosModules.default
        inputs.nix-flatpak.nixosModules.nix-flatpak

        ./../../modules/system/sddm.nix
        ./../../modules/system/locale.nix
        ./../../modules/system/games.nix
        ./../../modules/system/flatpack.nix
        ./../../modules/system/mounting.nix
        ./../../modules/system/AI.nix
        ./../../modules/system/sops.nix
        ./../../modules/system/xdg.nix
    ];

   # NixOS Settings with Home Manager
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


  networking.hostName = "gaia"; # Define your hostname.
  networking.firewall = {
    trustedInterfaces = [ "docker0" ];
  };

  # Enable networking
  networking.networkmanager.enable = true;
  # enable systemd DNS resolver
  services.resolved.enable = true;
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # ------------------------------ #

    # Enable the X11 windowing system.
    # You can disable this if you're only using the Wayland session.
    #services.xserver.enable = true;

    # Enable the KDE Plasma Desktop Environment.
    #services.displayManager.sddm.enable = true;
    services.desktopManager.plasma6.enable = true;

    environment.sessionVariables = {
        RADV_PERFTEST     = "gpl";                        # AMD: Shader-Ruckler reduzieren
        PATH              = [ "$HOME/.local/bin" ];
        PULSE_COOKIE      = "$HOME/.config/pulse/cookie"; # greift nicht für Steam (eigene libpulse)
        COPILOT_HOME      = "$HOME/.config/copilot";      # undokumentiert, kann per VSCode-Update wegfallen
        CLAUDE_CONFIG_DIR = "$HOME/.config/claude";       # undokumentiert; VSCode-Ext. ignoriert sie
    };


    xdg.portal = {
        enable = true;
        extraPortals = with pkgs; [
            kdePackages.xdg-desktop-portal-kde
            xdg-desktop-portal-gtk
        ];
    };

    # ------------------------------ # Hardware und Treiber

    hardware = {
        graphics = {
        enable = true;
        enable32Bit = true;
        };
    };


    services.printing = {
        enable = true;
        drivers = with pkgs; [
            epson-escpr
            epson-escpr2  # treiber für meinen Espson WF-26xx
        ];
    };

    services.avahi = {
        enable = true;
        nssmdns4 = true;
        openFirewall = true;
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


    services.udev.packages = with pkgs; [
      platformio-core.udev
      openocd
    ];

    services.openssh = {
      enable = true;
      listenAddresses = [{ addr = "172.17.0.1"; port = 22; }];
      settings.PasswordAuthentication = false;
    };


  # Fix für die ARM-Toolchain, damit sie die benötigten Libs findet
    programs.nix-ld = {
        enable = true;
    
        # Ggf. zusätzliche Libs für den ARM-Toolchain
        libraries = with pkgs; [
            stdenv.cc.cc.lib
            zlib
            libusb1
            libxcb
            icu

            fontconfig
            freetype
            libGL
            libX11
            libXext
            libICE
            libSM
            libXi
            libXrender
            libXrandr
            libXcursor
            libXinerama
            libxkbcommon

            gnutls
        ];
    };

  # Define a user account. Don't forget to set a password with ‘passwd’.
    users.users.bhoesch = {
        isNormalUser = true;
        description = "Bjarne Hösch";
        uid = 1000;
        extraGroups = [ "networkmanager" "wheel" "docker"];
        packages = with pkgs; [
        kdePackages.kate
        ];
        shell = pkgs.zsh;
    };

  programs.zsh.enable = true;

  home-manager = {

    # Fix use of unfree packages
    useGlobalPkgs = true;
    useUserPackages = true;
    backupFileExtension = "hm-bak";
    overwriteBackup = true;

    extraSpecialArgs = { inherit inputs; };
    users = {
      bhoesch = import ./home.nix;
    };
  };


  services = {

    ratbagd.enable = true; # mice configuration service(needed for piper)
    input-remapper.enable = true;
    mullvad-vpn.enable = true;
  
  };

  virtualisation.docker.enable = true; # to enable the docker deamon


  # Install System packages.
  programs = {

    gamescope.enable = true;
    gamemode.enable = true;

  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  fonts.packages = with pkgs; [
    # ttf-ms-fonts
    # ttf-vista-fonts
    # ttf-liberation
    # ttf-dejavu
    # ttf-roboto
    # ttf-fira-code
    # ttf-jetbrains-mono
    corefonts
    vista-fonts
    #nerd-fonts
  ];


    # Vulkan / graphics stack needed for DXVK translation layer used by Bottles runners
    hardware.graphics.extraPackages = with pkgs; [
        libva-vdpau-driver
        libvdpau-va-gl
    ];

    programs.steam = {
        enable = true;
        package = pkgs.steam.override {
          extraEnv = {
            MANGOHUD = true;
          };
        };
    };

    environment.systemPackages = with pkgs; [

        home-manager
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
        #helvum #Pipewire configuration with gui #not maintained
        crosspipe # Pipewire configuration with gui, maintained fork of helvum
        libstrangle
        rustdesk # Remote Zugriff auf Laptop

        github-desktop
        #python312
        python315
        unrar
        geogebra
        #globalprotect-openconnect # see error note
        gpclient
        #gp-saml-gui

        _1password-gui
        (discord.override {
            withOpenASAR = true;
            withVencord = true;
        })

        mullvad-vpn
        mullvad-browser

        whatsapp-electron
        libreoffice
        onlyoffice-desktopeditors
        zotero # citation manager
        obsidian # note taking app

        kdePackages.plasma-browser-integration
        kdePackages.kwallet
        kdePackages.kclock

        # Tools for Peripherie
        streamdeck-ui
        piper # for mouse config

        pavucontrol

        evtest # for debbuging of input signals
        xev
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
        bento4 # for mp4decrypt for Crunchayroll downloads
        corefonts
        vista-fonts

        gcc
        libgcc
        gnumake
        cmake
        #extra-cmake-modules
        #makemkv
        iperf3 # network performance measurement tool

        docker
        docker-compose
        lazydocker

        #bottles
        vulkan-tools

        #claude-code
        #claude-monitor
        gnutls

        # Guitare
        #guitarix

        sops 
        age
        openssl
        tailscale

    ];


  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.11"; # Did you read the comment?

}
