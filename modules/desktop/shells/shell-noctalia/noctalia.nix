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

    homeManager = {
      config,
      options,
      pkgs,
      ...
    }: {
      imports = [inputs.noctalia.homeModules.default];

      config = lib.mkMerge [
        {
          home.packages = with pkgs; [
            (writeShellScriptBin "menu-launcher" "exec noctalia msg panel-toggle launcher")
            (writeShellScriptBin "menu-clipboard" "exec noctalia msg panel-toggle clipboard")
          ];

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
                mode = "dark";
                source =
                  if config.theming.colorSource == "stylix"
                  then "custom"
                  else "wallpaper";
                custom_palette = "stylix";
                wallpaper_scheme = "m3-content";

                templates = {
                  enable_builtin_templates = config.theming.colorSource == "wallpaper";
                  builtin_ids = config.theming.noctaliaTemplates.builtin;

                  enable_community_templates = config.theming.colorSource == "wallpaper";
                  community_ids = config.theming.noctaliaTemplates.community;
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

              bar = {
                default = {
                  position = "top"; # top | bottom | left | right
                  enabled = true;
                  auto_hide = false; # slide out after pointer leaves; reveal from edge trigger strip
                  smart_auto_hide = false; # show when the active workspace is empty; hide when it has windows
                  show_on_workspace_switch = true; # with auto_hide: briefly reveal when the active workspace changes
                  reserve_space = true; # reserve compositor exclusive zone / push windows away
                  layer = "top"; # top | overlay; overlay appears above fullscreen apps

                  thickness = 38; # bar cross-axis size in pixels (height for horizontal, width for vertical)
                  background_opacity = 1.0; # 0.0 (transparent) to 1.0 (opaque)
                  border = "outline"; # color role or #RRGGBB for the bar outline
                  border_width = 0.0; # inside outline width in pixels; 0 disables it
                  shadow = true; # cast the global [shell.shadow]
                  contact_shadow = false; # dark gradient between an attached panel and the bar (depth at the seam)
                  panel_overlap = 1; # logical px an attached panel overlaps the bar edge to hide the seam
                  radius = 12; # global corner radius fallback
                  radius_top_left = 12;
                  radius_top_right = 12;
                  radius_bottom_left = 12;
                  radius_bottom_right = 12;
                  concave_edge_corners = true; # carve the screen-edge corners inward; requires margin_edge = 0
                  margin_ends = 100; # inset from each end of the bar along its main axis
                  margin_edge = 0; # distance from the nearest screen edge (positive values float the bar)
                  margin_opposite_edge = 0; # extra reserved space on the inward side of the bar (below for top, above for bottom)
                  padding = 14; # main-axis padding from bar edges to start/end widget sections
                  widget_spacing = 8; # gap between widgets within a section
                  hover_highlight = true; # softly tint the widget under the mouse pointer with its foreground color
                  scale = 1.1; # content scale multiplier for icons and text
                  font_weight = 500; # CSS weight 100–1000 (e.g. 400 regular, 700 bold); primary label weight for bar widgets
                  font_family = ""; # typeface for this bar's widgets; empty inherits the global font

                  # Default capsule style for all widgets on this bar (see Widget Capsule section)
                  capsule = false;
                  capsule_fill = "surface_variant";
                  capsule_thickness = 0.76; # capsule size across the bar as a fraction of bar thickness (1.0 fills the bar)
                  capsule_radius = 8.0; # omit for automatic pill radius
                  capsule_opacity = 1.0;
                  # capsule_border   = "outline"   # omit this key for no border by default

                  start = ["launcher" "wallpaper" "workspaces"];
                  center = ["clock"];
                  end = ["media" "tray" "notifications" "clipboard" "network" "bluetooth" "volume" "brightness" "battery" "control-center" "session"];
                };
              };

              widget = {
                workspaces = {
                  show_labels = true; # false = unlabeled pills (Focus Hint: app icon only)
                  label_source = "name"; # id | name
                  max_label_chars = 6; # truncate long workspace names (e.g. "VESKTOP" → "VE")
                };
              };
            };
          };
        }

        # ======== nur wenn Hyprland aktiv ist =========================
        # Option existiert immer (HM-Builtin), daher Prüfung auf `enable`.
        (lib.mkIf config.wayland.windowManager.hyprland.enable {
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
        })

        # ======== nur wenn niri aktiv ist =============================
        (lib.mkIf config.wayland.windowManager.niri.enable {
          wayland.windowManager.niri.settings = {
            # Ohne das funktionieren Notification-Actions und Fenster-
            # Aktivierung aus Noctalia heraus nicht.
            debug."honor-xdg-activation-with-invalid-serial" = [];

            # Wallpaper bleibt stehen, statt mit den Workspaces zu scrollen.
            layout.background-color = "transparent";
            overview.workspace-shadow.off = [];

            binds = {
              "Mod+S"."spawn-sh" = "noctalia msg panel-toggle control-center";
              "Mod+Shift+Comma"."spawn-sh" = "noctalia msg settings-toggle";
              "Alt+Tab"."spawn-sh" = "noctalia msg window-switcher";
            };

            _children = [
              {
                layer-rule = {
                  match._props.namespace = "^noctalia-wallpaper";
                  place-within-backdrop = true;
                };
              }
              {
                layer-rule = {
                  match._props.namespace = "^noctalia-(bar-.+|notification|dock|panel|attached-panel|osd|window-switcher)$";
                  background-effect = {
                    blur = true;
                    xray = true;
                  };
                };
              }
              {
                window-rule = {
                  match._props.app-id = "^dev\\.noctalia\\.Noctalia$";
                  open-floating = true;
                  default-column-width.fixed = 1080;
                  default-window-height.fixed = 920;
                };
              }
            ];
          };
        })
      ];
    };
  };
}
