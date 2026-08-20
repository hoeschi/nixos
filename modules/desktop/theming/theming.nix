{den, ...}: {
  den.aspects.gui.provides.theming = {
    homeManager = {
      lib,
      config,
      ...
    }: {
      options.theming.colorSource = lib.mkOption {
        type = lib.types.enum ["stylix" "wallpaper"];
        default = "stylix";
        description = ''
          stylix    – statisches base16-Schema, build-time, Stylix schreibt die Configs.
          wallpaper – Noctalia extrahiert die Palette aus dem aktiven Wallpaper (M3)
                      und rendert die Configs zur Laufzeit neu.
        '';
      };

      config.stylix.targets = let
        fromStylix = config.theming.colorSource == "stylix";
      in {
        # Farbquellen-abhängig. Im Wallpaper-Modus übernimmt das
        # jeweils angemerkte Noctalia-Template.
        kitty.enable = fromStylix; # → builtin "kitty"
        gtk.enable = fromStylix; # → builtin "gtk3" + "gtk4"
        qt.enable = fromStylix; # → builtin "qt"
        hyprland.enable = fromStylix; # → builtin "hyprland"
        vscode.enable = fromStylix; # → community "vscode"
        noctalia.enable = fromStylix; # → theme.source = "wallpaper"

        firefox = {
          enable = fromStylix; # → community "pywalfox"
          profileNames = ["default"];
        };

        # Immer Stylix: kein Noctalia-Template vorhanden, oder nur im
        # classic-Profil aktiv, wo es gar keine Wallpaper-Palette gibt.
        fontconfig.enable = true;
        font-packages.enable = true;
        dunst.enable = true;
        waybar.enable = true;
        rofi.enable = true;
        kde.enable = true;
      };
    };
  };
}
