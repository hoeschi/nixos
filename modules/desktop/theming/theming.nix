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
          Woher die Farben der Oberfläche kommen.

          stylix    – statisches base16-Schema, zur Build-Zeit festgelegt.
                      Stylix schreibt die App-Configs.
          wallpaper – Noctalia extrahiert die Palette aus dem aktiven Wallpaper
                      und rendert die App-Configs zur Laufzeit neu.

          Die Gegenstücke der abschaltbaren Targets stehen als Noctalia-Template-IDs
          in shells/shell-noctalia/noctalia.nix und müssen dazu passen.
        '';
      };

      config.stylix.targets = let
        fromStylix = config.theming.colorSource == "stylix";
      in {
        # ── Farbquellen-abhängig ────────────────────────────────────────
        # Im Wallpaper-Modus übernimmt das jeweils angemerkte Noctalia-Template.
        kitty.enable = fromStylix; # → builtin  "kitty"
        gtk.enable = fromStylix; # → builtin  "gtk3" + "gtk4"
        qt.enable = fromStylix; # → builtin  "qt"
        hyprland.enable = fromStylix; # → builtin  "hyprland"
        vscode.enable = fromStylix; # → community "vscode"
        firefox.enable = fromStylix; # → community "pywalfox"
        noctalia.enable = fromStylix; # → theme.source = "wallpaper"

        # ── Immer Stylix ────────────────────────────────────────────────
        # Kein Noctalia-Template vorhanden, oder nur im classic-Profil aktiv,
        # wo es gar keine Wallpaper-Palette gibt.
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
