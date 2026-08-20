{den, ...}: {
  den.aspects.gui.provides.theming = {
    homeManager = {
      lib,
      config,
      ...
    }: {
      options.theming = {
        colorSource = lib.mkOption {
          type = lib.types.enum ["stylix" "wallpaper"];
          default = "stylix";
          description = ''
            Woher die Farben der Oberfläche kommen.

            stylix    – statisches base16-Schema, zur Build-Zeit festgelegt.
                        Stylix schreibt die App-Configs.
            wallpaper – Noctalia extrahiert die Palette aus dem aktiven Wallpaper
                        und rendert die App-Configs zur Laufzeit neu.
          '';
        };

        noctaliaOwns = lib.mkOption {
          type = lib.types.listOf (lib.types.enum [
            "kitty"
            "gtk"
            "qt"
            "hyprland"
            "niri"
            "vscode"
            "firefox"
          ]);
          default = [];
          description = ''
            Apps, deren Farben im Wallpaper-Modus von Noctalia kommen:
            Stylix-Target aus, passendes Template an. Eine App kommt erst hier
            rein, wenn ihr Glue steht (Include-Zeile, Extension, o.ä.).
            Im Stylix-Modus ohne Wirkung.
          '';
        };

        noctaliaTemplates = lib.mkOption {
          type = lib.types.attrsOf (lib.types.listOf lib.types.str);
          internal = true;
          description = "Abgeleitet aus noctaliaOwns, gelesen von noctalia.nix.";
        };
      };

      config = let
        wallpaper = config.theming.colorSource == "wallpaper";
        owns = app: wallpaper && builtins.elem app config.theming.noctaliaOwns;

        # App → Noctalia-Template-IDs. Einzige Stelle mit dieser Zuordnung.
        templateIds = {
          kitty.builtin = ["kitty"];
          gtk.builtin = ["gtk3" "gtk4"];
          qt.builtin = ["qt"];
          hyprland.builtin = ["hyprland"];
          niri.builtin = ["niri"];
          vscode.community = ["vscode"];
          firefox.community = ["pywalfox"];
        };

        idsFor = kind:
          lib.concatMap (app: templateIds.${app}.${kind} or [])
          config.theming.noctaliaOwns;
      in {
        theming.noctaliaTemplates = {
          builtin = lib.optionals wallpaper (idsFor "builtin");
          community = lib.optionals wallpaper (idsFor "community");
        };

        stylix.targets = {
          # ── Besitz wechselt pro App ─────────────────────────────────────
          kitty.enable = !owns "kitty";
          gtk.enable = !owns "gtk";
          qt.enable = !owns "qt";
          hyprland.enable = !owns "hyprland";
          vscode.enable = !owns "vscode";
          firefox.enable = !owns "firefox";
          # niri hat kein Stylix-Target, deshalb hier keine Zeile.

          # ── Die Shell selbst ────────────────────────────────────────────
          # Im Wallpaper-Modus darf Stylix theme.source nicht auf "custom" ziehen.
          noctalia.enable = !wallpaper;

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
  };
}
