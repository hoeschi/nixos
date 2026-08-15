{ inputs, den, lib, ... }: 
{

  flake.den = den;

  imports = [ 
    inputs.den.flakeModule 
  ];


  den.default = {
    homeManager.home.stateVersion = "25.11";

    nixos = {...}: {
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
    };
  };
  #den.aspects.gaia = { # (6)
  #
  #  includes = [ den.batteries.hostname ]; # (7)
  #  nixos = { pkgs, ... }: {
  #    imports = [ ./_nixos/configuration.nix ]; # (8)
  #    environment.systemPackages = [ pkgs.hello ];
  #  };
  #};
  #
  #den.aspects.bhoesch = { # (9)
  #
  #  includes = [ den.batteries.define-user den.batteries.primary-user ]; # (10)
  #  homeManager = { pkgs, ... }: {
  #    home.packages = [ pkgs.vim ];
  #  };
  #};
}