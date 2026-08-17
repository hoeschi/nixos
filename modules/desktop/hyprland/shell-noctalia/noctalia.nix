{
  den,
  inputs,
  ...
}: {
  den.aspects.gui.provides.noctalia = {
    nixos = {
      # Noctalia erwartet diese Dienste für Batterie-, Power- und Netzwerk-Widgets.
      services.upower.enable = true;
      services.power-profiles-daemon.enable = true;
    };

    homeManager = {config, ...}: let
      c = config.lib.stylix.colors.withHashtag;
      # base16 -> Noctalia-Rollen. Stylix bleibt einzige Farbquelle,
      # Noctalia bekommt sie als Build-Artefakt.
      #      palette = {
      #        mPrimary = c.base0D; # Blau, wie der Waybar-Akzent
      #        mOnPrimary = c.base00;
      #        mSecondary = c.base0E; # Magenta
      #        mOnSecondary = c.base00;
      #        mTertiary = c.base0A; # Gelb
      #        mOnTertiary = c.base00;
      #        mError = c.base08; # Rot
      #        mOnError = c.base00;
      #        mSurface = c.base00;
      #        mOnSurface = c.base05;
      #        mSurfaceVariant = c.base01;
      #        mOnSurfaceVariant = c.base04;
      #        mOutline = c.base03;
      #        mShadow = c.base00;
      #        mHover = c.base02;
      #        mOnHover = c.base05;
      #      };
    in {
      imports = [inputs.noctalia.homeModules.default];

      programs.noctalia = {
        enable = true;
        systemd.enable = true;

        settings.theme = {
          mode = "dark";
          source = "custom";
          custom_palette = "stylix"; # Dateiname ohne .json

          # Stylix behält die App-Configs. Explizit aus, damit ein
          # GUI-Klick das nicht unbemerkt umdreht.
          templates = {
            enable_builtin_templates = false;
            enable_community_templates = false;
            enable_user_templates = false;
            builtin_ids = [];
            community_ids = [];
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
