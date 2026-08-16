{den, ...}: {
  den.aspects.gui.provides.hyprland = {
    homeManager = {
      services.dunst = {
        enable = true;

        settings = {
          global = {
            # ── Position & Size ──────────────────────────────────
            width = "(300, 450)"; # dynamisch: wächst mit dem Text
            height = "(0, 400)"; # KEINE Mindesthöhe -> kein Leerraum
            origin = "top-right";
            offset = "(15, 15)";
            gap_size = 8; # echter Abstand zwischen Popups
            notification_limit = 5;
            layer = "overlay"; # auch über Fullscreen sichtbar

            # ── Optik ─────────────────────────────────────────────
            frame_width = 2;
            corner_radius = 5; # = decoration.rounding aus hyprland.nix
            separator_height = 0; # überflüssig, da gap_size > 0
            padding = 12;
            horizontal_padding = 14;
            text_icon_padding = 12;
            transparency = 10;

            # Fortschrittsbalken (Volume, Brightness, ...)
            # Farbe = `highlight`, kommt von Stylix.
            progress_bar = true;
            progress_bar_height = 8;
            progress_bar_corner_radius = 4;
            progress_bar_frame_width = 0;

            # ── Text ──────────────────────────────────────────────
            markup = "full";
            format = "<b>%s</b>\\n%b"; # \\n -> literales \n in der ini
            alignment = "left";
            vertical_alignment = "center";
            ellipsize = "end";
            word_wrap = true;
            show_age_threshold = 60;

            # ── Icons ─────────────────────────────────────────────
            icon_position = "left";
            min_icon_size = 32;
            max_icon_size = 64;

            # ── Verhalten ─────────────────────────────────────────
            indicate_hidden = true;
            stack_duplicates = true;
            hide_duplicate_count = false;
            show_indicators = false; # keine "(A)"-Action-Marker
            sticky_history = true;
            history_length = 25;
            sort = "urgency_descending";
            idle_threshold = 120; # bei Inaktivität nicht wegtimen

            mouse_left_click = "close_current";
            mouse_middle_click = "do_action, close_current";
            mouse_right_click = "close_all";
          };

          urgency_low = {
            timeout = 5;
          };
          urgency_normal = {
            timeout = 10;
          };
          urgency_critical = {
            timeout = 0;
          };
        };
      };
    };
  };
}
