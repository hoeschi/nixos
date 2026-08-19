{
  den,
  lib,
  ...
}: {
  den.aspects.gui.provides.niri = {
    includes = [
      den.aspects.gui.provides.wayland-base
    ];

    nixos = {pkgs, ...}: {
      programs.niri = {
        enable = true;

        # Default ist true und zieht nautilus über services.dbus.packages rein,
        # nur damit der GNOME-Portal-Filechooser funktioniert. gtk reicht.
        useNautilus = false;
      };

      # Das niri-Modul setzt defaultSession per mkDefault auf "niri".
      # Im Parallelbetrieb soll Hyprland die Vorauswahl im SDDM bleiben.
      services.displayManager.defaultSession = "hyprland";
    };

    homeManager = {
      config,
      pkgs,
      ...
    }: {
      wayland.windowManager.niri = {
        enable = true;

        # Units kommen systemweit aus programs.niri (systemd.packages).
        # package bleibt gesetzt, sonst fällt checkConfig weg.
        systemd.enable = false;

        settings = {
          prefer-no-csd = [];
          screenshot-path = "${config.xdg.userDirs.pictures}/Screenshots/%Y-%m-%d %H-%M-%S.png";
          hotkey-overlay.skip-at-startup = [];

          # niri legt die X11-Sockets selbst an und startet Satellite on-demand,
          # sobald ein X11-Client verbindet. Ohne das kein Steam, Proton, Ryujinx.
          xwayland-satellite.path = lib.getExe pkgs.xwayland-satellite;

          input = {
            keyboard = {
              numlock = [];
              xkb.layout = "de";
            };
            mouse.accel-profile = "flat";
            focus-follows-mouse = [];
          };

          cursor = {
            xcursor-theme = config.stylix.cursor.name;
            xcursor-size = config.stylix.cursor.size;
          };

          layout = {
            gaps = 10;
            center-focused-column = "never";
            empty-workspace-above-first = [];

            focus-ring.off = [];
            border = with config.lib.stylix.colors.withHashtag; {
              on = [];
              width = 2;
              active-color = base0D;
              inactive-color = base03;
            };

            default-column-width.proportion = 0.5;
            preset-column-widths._children = [
              {proportion = 1.0 / 3.0;}
              {proportion = 0.5;}
              {proportion = 2.0 / 3.0;}
            ];
            preset-window-heights._children = [
              {proportion = 1.0 / 3.0;}
              {proportion = 0.5;}
              {proportion = 2.0 / 3.0;}
            ];
          };

          blur = {
            passes = 2;
            offset = 3.0;
            noise = 0.02;
          };

          binds = {
            "Mod+Return"."spawn" = ["kitty"];
            "Mod+Z"."spawn" = ["kitty" "-e" "rmpc"];
            "Mod+Space"."spawn" = ["menu-launcher"];
            "Mod+V"."spawn" = ["menu-clipboard"];
            "Mod+Q"."close-window" = [];
            "Mod+Shift+M"."quit" = [];
            "Mod+Shift+Slash"."show-hotkey-overlay" = [];
            "Mod+Shift+S"."screenshot" = [];
            "Mod+I"."spawn-sh" = "notify-send 'Active window:' \"$(niri msg focused-window)\"";

            # Links/rechts sind Spalten, hoch/runter Fenster in der Spalte
            "Mod+Left"."focus-column-left" = [];
            "Mod+Right"."focus-column-right" = [];
            "Mod+Up"."focus-window-or-workspace-up" = [];
            "Mod+Down"."focus-window-or-workspace-down" = [];
            "Mod+Shift+Left"."move-column-left" = [];
            "Mod+Shift+Right"."move-column-right" = [];
            "Mod+Shift+Up"."move-window-up-or-to-workspace-up" = [];
            "Mod+Shift+Down"."move-window-down-or-to-workspace-down" = [];

            "Mod+Comma"."consume-or-expel-window-left" = [];
            "Mod+Period"."expel-window-from-column" = [];
            "Mod+R"."switch-preset-column-width" = [];
            "Mod+C"."center-column" = [];
            "Mod+W"."toggle-column-tabbed-display" = [];

            "Mod+H"."toggle-window-floating" = [];
            "Mod+Shift+H"."switch-focus-between-floating-and-tiling" = [];
            "Mod+F"."maximize-column" = [];
            "Mod+T"."fullscreen-window" = [];
            "Mod+Tab"."toggle-overview" = [];

            # Benannte Workspaces – wechseln bei Bedarf auch den Monitor
            "Mod+B"."focus-workspace" = "browser";
            "Mod+M"."focus-workspace" = "media";
            "Mod+G"."focus-workspace" = "games";
            "Mod+Shift+B"."move-column-to-workspace" = "browser";
            "Mod+Shift+G"."move-column-to-workspace" = "games";

            # ACHTUNG: Indizes sind PRO MONITOR, nicht global.
            "Mod+1"."focus-workspace" = 1;
            "Mod+2"."focus-workspace" = 2;
            "Mod+3"."focus-workspace" = 3;
            "Mod+4"."focus-workspace" = 4;
            "Mod+5"."focus-workspace" = 5;
            "Mod+6"."focus-workspace" = 6;
            "Mod+7"."focus-workspace" = 7;
            "Mod+8"."focus-workspace" = 8;
            "Mod+9"."focus-workspace" = 9;

            "Mod+Shift+1"."move-column-to-workspace" = 1;
            "Mod+Shift+2"."move-column-to-workspace" = 2;
            "Mod+Shift+3"."move-column-to-workspace" = 3;
            "Mod+Shift+4"."move-column-to-workspace" = 4;
            "Mod+Shift+5"."move-column-to-workspace" = 5;
            "Mod+Shift+6"."move-column-to-workspace" = 6;
            "Mod+Shift+7"."move-column-to-workspace" = 7;
            "Mod+Shift+8"."move-column-to-workspace" = 8;
            "Mod+Shift+9"."move-column-to-workspace" = 9;

            # Numpad. niri matcht gegen den UNMODIFIZIERTEN Keysym
            # (raw_latin_sym_or_raw_current_sym), deshalb die Level-0-Namen
            # und nicht KP_1..KP_9. Vorher mit `wev` gegenprüfen.
            "Mod+KP_End"."focus-workspace" = 1;
            "Mod+KP_Down"."focus-workspace" = 2;
            "Mod+KP_Next"."focus-workspace" = 3;
            "Mod+KP_Left"."focus-workspace" = 4;
            "Mod+KP_Begin"."focus-workspace" = 5;
            "Mod+KP_Right"."focus-workspace" = 6;
            "Mod+KP_Home"."focus-workspace" = 7;
            "Mod+KP_Up"."focus-workspace" = 8;
            "Mod+KP_Prior"."focus-workspace" = 9;

            "Mod+WheelScrollUp"."focus-column-left" = [];
            "Mod+WheelScrollDown"."focus-column-right" = [];

            "Mod+Ctrl+Left"."focus-monitor-left" = [];
            "Mod+Ctrl+Right"."focus-monitor-right" = [];
            "Mod+Ctrl+Shift+Left"."move-column-to-monitor-left" = [];
            "Mod+Ctrl+Shift+Right"."move-column-to-monitor-right" = [];

            "XF86AudioPlay"."spawn" = ["playerctl" "play-pause"];
            "XF86AudioRaiseVolume" = {
              _props."allow-when-locked" = true;
              spawn = ["wpctl" "set-volume" "-l" "1.5" "@DEFAULT_AUDIO_SINK@" "2%+"];
            };
            "XF86AudioLowerVolume" = {
              _props."allow-when-locked" = true;
              spawn = ["wpctl" "set-volume" "-l" "1.5" "@DEFAULT_AUDIO_SINK@" "2%-"];
            };
          };

          # Wiederholte Top-Level-Nodes müssen über _children laufen,
          # weil ein Attrset denselben Key nur einmal haben kann.
          _children = [
            # ======== Outputs ==========================================
            {
              output = {
                _args = ["DP-2"];
                mode = "2560x1440@143.86";
                position._props = {
                  x = 0;
                  y = 0;
                };
                scale = 1;
                variable-refresh-rate._props.on-demand = true;
                focus-at-startup = [];
              };
            }
            {
              output = {
                _args = ["HDMI-A-1"];
                mode = "2560x1440@75.00";
                position._props = {
                  x = 2560;
                  y = 0;
                };
                scale = 1;
              };
            }

            # ======== Benannte Workspaces ==============================
            # Persistent und an einen Output gebunden. Alles weitere dynamisch.
            {
              workspace = {
                _args = ["browser"];
                open-on-output = "HDMI-A-1";
              };
            }
            {
              workspace = {
                _args = ["media"];
                open-on-output = "HDMI-A-1";
              };
            }
            {
              workspace = {
                _args = ["games"];
                open-on-output = "DP-2";
              };
            }

            # ======== Window-Rules =====================================
            {
              window-rule = {
                geometry-corner-radius = 5;
                clip-to-geometry = true;
              };
            }
            {
              window-rule = {
                match._props.app-id = "^kitty$";
                opacity = 0.9;
                background-effect.blur = true;
              };
            }
            {
              window-rule = {
                match._props.app-id = "^code$";
                opacity = 0.95;
              };
            }
            {
              window-rule = {
                match._props.app-id = "^firefox$";
                open-on-workspace = "browser";
              };
            }
            {
              window-rule = {
                match._props.title = "^Picture-in-Picture$";
                open-floating = true;
                default-floating-position._props = {
                  x = 20;
                  y = 20;
                  relative-to = "bottom-right";
                };
              };
            }
            {
              window-rule = {
                match._props.app-id = "^steam$";
                open-on-workspace = "games";
              };
            }
            {
              window-rule = {
                _children = [
                  {
                    match._props = {
                      app-id = "^steam$";
                      title = "^Screenshot Manager$";
                    };
                  }
                  {
                    match._props = {
                      app-id = "^steam$";
                      title = "^Friends List$";
                    };
                  }
                ];
                open-floating = true;
              };
            }
            {
              window-rule = {
                match._props.app-id = "^steam_app_\\d+$";
                open-on-workspace = "games";
                open-fullscreen = true;
                variable-refresh-rate = true;
                geometry-corner-radius = 0;
              };
            }
            {
              window-rule = {
                match._props.app-id = "^com\\.github\\.hluk\\.copyq$";
                open-floating = true;
                default-column-width.fixed = 800;
                default-window-height.fixed = 600;
              };
            }
          ];
        };
      };
    };
  };
}
