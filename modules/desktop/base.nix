{den, ...}: {
  den.aspects.gui.provides.wayland-base = {
    includes = [
      den.aspects.gui.provides.theming
      den.aspects.shell.provides.kitty
    ];

    nixos = {
      lib,
      config,
      ...
    }: {
      # GTK-Apps (Nemo & Co.) lesen gtk-theme/color-scheme über GSettings.
      # Ohne dconf-Backend landen die Werte im Memory-Backend und gehen verloren.
      programs.dconf.enable = lib.mkIf (config.theming.colorSource == "wallpaper") true;
    };

    homeManager = {
      lib,
      config,
      pkgs,
      ...
    }: {
      config = lib.mkMerge [
        {
          home.packages = with pkgs; [
            libnotify

            grim
            slurp

            wl-clipboard # for Screenshot functionality

            playerctl
          ];

          services.playerctld.enable = true;
        }

        # ======== GTK im Wallpaper-Modus ===============================
        # Stylix-Targets sind aus, also übernimmt Noctalia (Templates gtk3/gtk4
        # in noctalia.nix). Das Template schreibt ~/.config/gtk-{3,4}.0/noctalia.css
        # und hängt den @import an gtk.css an. Die Farben sind aber nur Overrides
        # für adw-gtk3 – ohne das Theme bleibt GTK3 im hellen Adwaita-Default.
        #
        # Bewusst NICHT das HM-gtk-Modul: das würde gtk.css als read-only Symlink
        # verwalten, und Noctalia muss dort reinschreiben.
        (lib.mkIf (config.theming.colorSource == "wallpaper") {
          home.packages = [pkgs.adw-gtk3];

          dconf.settings."org/gnome/desktop/interface" = {
            gtk-theme = "adw-gtk3-dark";
            color-scheme = "prefer-dark";
          };
        })
      ];
    };
  };
}
