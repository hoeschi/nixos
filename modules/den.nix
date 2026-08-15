{ inputs, den, ... }: 
{

  #flake.den = den;

  imports = [ 
    inputs.den.flakeModule 
  ];


  den.default = {

    nixos = {pkgs, ...}: {
      # Localization
      time.timeZone = "Europe/Berlin";

      i18n.defaultLocale = "de_DE.UTF-8";
      i18n.extraLocaleSettings = {
        LC_ADDRESS = "de_DE.UTF-8";
        LC_IDENTIFICATION = "de_DE.UTF-8";
        LC_MEASUREMENT = "de_DE.UTF-8";
        LC_MONETARY = "de_DE.UTF-8";
        LC_NAME = "de_DE.UTF-8";
        LC_NUMERIC = "de_DE.UTF-8";
        LC_PAPER = "de_DE.UTF-8";
        LC_TELEPHONE = "de_DE.UTF-8";
        LC_TIME = "de_DE.UTF-8";
      };

      services.xserver.xkb = {
        layout = "de";
        variant = "";
      };

      console.keyMap = "de";
      
      home-manager = {
        # Fix use of unfree packages
        useGlobalPkgs = true;
        useUserPackages = true;
        backupFileExtension = "hm-bak";
        overwriteBackup = true;
      };

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
    };
  };

  den.schema.host.includes = [
    {
      # XDG Base Directory Specification – systemweit für alle Sessions.
      # Wird via PAM (/etc/pam/environment) gesetzt, gilt also auch für
      # grafische Logins über SDDM, nicht nur für Login-Shells.
      environment.sessionVariables = {
        XDG_CACHE_HOME  = "$HOME/.cache";
        XDG_CONFIG_HOME = "$HOME/.config";
        XDG_DATA_HOME   = "$HOME/.local/share";
        XDG_STATE_HOME  = "$HOME/.local/state";
        PLATFORMIO_CORE_DIR = "$HOME/.local/share/platformio";
        DOTNET_CLI_HOME     = "$HOME/.local/share/dotnet";
      };

      # Verzeichnisse deklarativ anlegen, statt sich darauf zu verlassen,
      # dass jedes Programm das selbst tut. %h = Home des jeweiligen Users.
      systemd.user.tmpfiles.rules = [
        "d %h/.cache        0700 - - -"
        "d %h/.config       0755 - - -"
        "d %h/.local        0755 - - -"
        "d %h/.local/share  0755 - - -"
        "d %h/.local/state  0755 - - -"
      ];
    }
  ];

}