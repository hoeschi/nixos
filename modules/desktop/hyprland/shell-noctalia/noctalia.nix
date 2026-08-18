{
  den,
  inputs,
  lib,
  ...
}: {
  den.aspects.gui.provides.noctalia = {
    nixos = {
      # Noctalia erwartet diese Dienste für Batterie-, Power- und Netzwerk-Widgets.
      services.upower.enable = true;
      services.power-profiles-daemon.enable = true;
    };

    homeManager = {config, ...}: {
      imports = [inputs.noctalia.homeModules.default];

      programs.noctalia = {
        enable = true;
        systemd.enable = true;

        settings = {
          shell = {
            launch_apps_as_systemd_services = true;
            panel.transparency_mode = "glass";
            lang = "en_US";
          };

          theme = {
            source = "custom";
            custom_palette = "stylix"; # Dateiname ohne .json
            templates = {
              enable_builtin_templates = false;
              enable_community_templates = false;

              builtin_ids = [];
              community_ids = [];
            };
          };
          services = {
            calendar = {
              enabled = true;
            };
          };

          control_center = {
            calendar = {
              show_week_numbers = true;
            };
          };

          wallpaper = {
            enabled = true;
            fill_mode = "fit";
            directory = "${config.xdg.userDirs.pictures}/Wallpapers";
            default.path = "${config.xdg.userDirs.pictures}/Wallpapers/default.png";
            transition_on_startup = true;
          };
        };
      };

      wayland.windowManager.hyprland.settings = {
        layer_rule = [
          {
            name = "Noctalia-Oberflächen: Blur, keine Hyprland-Animation";
            match.namespace = "^noctalia-(bar-.+|notification|dock|panel|attached-panel|osd|window-switcher)$";
            no_anim = true;
            ignore_alpha = 0.5;
            blur = true;
            blur_popups = true;
          }
        ];

        window_rule = [
          {
            name = "Noctalia-Einstellungsfenster schwebend";
            match.class = "dev.noctalia.Noctalia";
            float = true;
            size = "1080 920";
          }
        ];

        bind = let
          lua = lib.generators.mkLuaInline;
          bind = key: action: {_args = [key (lua action)];};
          exec = cmd: ''hl.dsp.exec_cmd("${cmd}")'';
        in [
          (bind "SUPER + S" (exec "noctalia msg panel-toggle control-center"))
          (bind "SUPER + comma" (exec "noctalia msg settings-toggle"))
          (bind "ALT + Tab" (exec "noctalia msg window-switcher"))
        ];
      };
    };
  };
}
