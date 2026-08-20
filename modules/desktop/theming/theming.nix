{den, ...}: {
  den.aspects.gui.provides.theming = {
    nixos = {lib, ...}: {
      options.theming.colorSource = lib.mkOption {
        type = lib.types.enum ["stylix" "wallpaper"];
        default = "stylix";
        description = ''
          Woher die Farben der Oberfläche kommen.

          stylix    – statisches base16-Schema, zur Build-Zeit festgelegt.
                      Stylix aktiviert alle Targets automatisch.
          wallpaper – Noctalia extrahiert die Palette aus dem aktiven Wallpaper.
                      Stylix-Targets sind aus und werden pro App explizit
                      wieder eingeschaltet, wo es kein Template gibt.

          Liegt auf NixOS-Ebene, weil stylix.autoEnable dort gebraucht wird.
          HM liest den Wert gespiegelt als config.theming.colorSource.
        '';
      };
    };

    homeManager = {
      lib,
      osConfig,
      ...
    }: {
      options.theming = {
        colorSource = lib.mkOption {
          type = lib.types.enum ["stylix" "wallpaper"];
          default = osConfig.theming.colorSource;
          description = "Spiegel der NixOS-Option, damit App-Module nicht osConfig lesen müssen.";
        };
      };
    };
  };
}
