{
  den,
  lib,
  ...
}: {
  den.aspects.gui.provides.hyprland = {
    includes = [
      den.aspects.shell.provides.kitty
    ];

    nixos = {
      programs.hyprland = {
        enable = true;
        xwayland.enable = true;
      };
    };

    homeManager = {pkgs, ...}: {
      home.packages = with pkgs; [
        dunst
        libnotify

        grim
        slurp

        awww # wallpaper demon
        rofi # programm starter | rofi-wayland merged into rofi
      ];

      services.hyprpolkitagent.enable = true;

      wayland.windowManager.hyprland = {
        enable = true; # enable Hyprland
        package = null; # use the default package
        portalPackage = null;
        xwayland.enable = true;
        systemd.enable = true;

        configType = "lua";

        settings = let
          monitor0 = "DP-2";
          monitor1 = "HDMI-A-1";
          mod = "SUPER";
        in {
          # Enable fallback for undefined ports
          monitor = [
            {
              output = monitor0;
              mode = "2560x1440@143.68";
              position = "0x0";
              scale = 1;
            }
            {
              output = monitor1;
              mode = "2560x1440@75.00";
              position = "2560x0";
              scale = 1;
            }
            {
              output = "";
              mode = "preferred";
              position = "auto";
              scale = 1;
            }
          ];

          on = {
            # Background processes
            _args = [
              "hyprland.start"
              (lib.generators.mkLuaInline ''
                function()
                  hl.exec_cmd("awww-daemon")              -- Wallpaper daemon
                  --hl.exec_cmd("quickshell --daemonize")   -- Desktop shell (widgets, overlays, ...)
                  --hl.exec_cmd("copyq --start-server")     -- Clipboard manager (wird über copyq.nix gestartet)
                end
              '')
            ];
          };

          config = {
            general = {
              gaps_in = 5; # Gaps between windows
              gaps_out = 10; # Gaps between windows and monitor edge
              border_size = 2; # Size of the border around windows

              # NOTE: Those are currently being set by stylix
              #          "col.active_border" = "rgba(7aa2f7ee) rgba(f7768eee) 30deg";  # Border color of active windows
              #          "col.inactive_border" = "rgba(595959aa)";                     # Border color of inactive windows

              layout = "dwindle"; # Default layout to use ("dwindle" | "master")
              hover_icon_on_border = false;
            };

            decoration = {
              rounding = 5; # Rounded window corners
              dim_modal = false; # Don't allow parent windows dimming out their own popup windows
              blur = {
                enabled = true; # Enable blurring of window backgrounds (kawase)
                size = 8; # Blur size (distance)
                passes = 1; # Amount of passes
                new_optimizations = true; # Enable optimizations
              };
            };

            animations = {
              enabled = true;
            };

            input = {
              # Keyboard
              kb_layout = "de"; # Base layout
              kb_variant = ""; # Variant (differing keys from base layout, e.g. colemak_dh)
              kb_model = ""; # Model (e.g. pc86, logitech_base, ...)
              kb_options = ""; # Options (japanese, euro sign position, ...)
              kb_rules = "";

              # Mouse
              sensitivity = 0; # Keep mouse sensitivity at default (-1.0 to 1.0)
              follow_mouse = 2; # Click another window to relocate focus to it
              mouse_refocus = true; # Focus overlay windows on mouse move
            };

            misc = {
              #disable_hyprland_logo = true; # Disable default Anime girl background
              #disable_splash_rendering = true; # Disable splash text
              animate_manual_resizes = true; # Play a small animation when resizing manually
              on_focus_under_fullscreen = 2; # Disable current fullscreen when opening a new window
              #vrr = 3; # Allow adaptive sync for fullscreen apps with `video` or `game` content type
            };

            render = {
              direct_scanout = 2; # Reduce lag for apps with content type `game`
              #cm_auto_hdr = 1; # Switch to fullscreen HDR if needed
            };

            cursor = {
              sync_gsettings_theme = true; # Sync xcursor theme with gsettings (GTK apps)
              enable_hyprcursor = true; # Enable hyprcursor support
            };

            ecosystem = {
              no_update_news = true; # Disable popup after wm update
              no_donation_nag = true; # Disable popup with wm donation request
            };

            # Dwindle layout
            dwindle = {
              force_split = 2; # Always split to the right / below
              preserve_split = true; # Keep split regardless of what happens to the container
            };
          };

          curve = [
            {
              _args = [
                "myBezier"
                (lib.generators.mkLuaInline "{type = \"bezier\", points = { {0.05, 0.9}, {0.1, 1.05} }}")
              ];
            }
          ];

          animation = [
            {
              leaf = "windows";
              enabled = true;
              speed = 7;
              bezier = "myBezier";
            }
            {
              leaf = "windowsOut";
              enabled = true;
              speed = 7;
              bezier = "default";
              style = "popin 80%";
            }
            {
              leaf = "border";
              enabled = true;
              speed = 10;
              bezier = "default";
            }
            {
              leaf = "borderangle";
              enabled = true;
              speed = 8;
              bezier = "default";
            }
            {
              leaf = "fade";
              enabled = true;
              speed = 7;
              bezier = "default";
            }
            {
              leaf = "workspaces";
              enabled = true;
              speed = 6;
              bezier = "default";
            }
          ];

          # Dedicate workspaces to monitors
          workspace_rule = [
            {
              workspace = 1;
              monitor = monitor0;
            }
            {
              workspace = 2;
              monitor = monitor0;
            }
            {
              workspace = 3;
              monitor = monitor1;
              #default_name = "Browser";
            }
            {
              workspace = 4;
              monitor = monitor1;
              #default_name = "Multimedia";
            }
            {
              workspace = 5;
              monitor = monitor1;
              #default_name = "Launchers";
            }
            {
              workspace = 10;
              monitor = monitor0;
              #default_name = "Games";
            }
          ];

          window_rule = [
            {
              name = "Visualize current working state of terminal windows";
              match.class = "^(kitty)$";
              opacity = "0.9 override 0.7 override";
            }
          ];

          bind = let
            lua = lib.generators.mkLuaInline;
            bind = key: action: {
              _args = [
                key
                (lua action)
              ];
            };

            exec = cmd: ''hl.dsp.exec_cmd("${cmd}")'';
            mvws = ws: ''hl.dsp.focus({ workspace = "${ws}" })'';
            mvwd = ws: ''hl.dsp.window.move({ workspace = "${ws}" })'';
            fs = mode: ''hl.dsp.window.fullscreen({ mode = "${mode}", action = "toggle" })'';
            focusdir = dir: ''hl.dsp.focus({ direction = "${dir}" })'';
            movedir = dir: ''hl.dsp.window.move({ direction = "${dir}" })'';
          in [
            (bind "${mod} + RETURN" (exec "kitty"))
            (bind "${mod} + Z" (exec "kitty -e rmpc"))
            #(bind "${mod} + SPACE" (exec "$HOME/.config/rofi/scripts/launcher.sh"))
            (bind "${mod} + SPACE" (exec "rofi -show drun"))
            #(bind "${mod} + S" (exec "$HOME/.config/hypr/scripts/screenshot.sh area"))
            #(bind "${mod} + N" (exec "$(eww get EWW_CONFIG_DIR)/scripts/toggle_popup sidebar"))
            (bind "${mod} + SHIFT + M" "hl.dsp.exit()") # exit Hyprland
            (bind "${mod} + SHIFT + R" (exec "hyprctl reload"))

            # Move to workspace
            (bind "${mod} + 1" (mvws "1"))
            (bind "${mod} + 2" (mvws "2"))
            (bind "${mod} + 3" (mvws "3"))
            (bind "${mod} + 4" (mvws "4"))
            (bind "${mod} + 5" (mvws "5"))
            (bind "${mod} + 6" (mvws "6"))
            (bind "${mod} + 7" (mvws "7"))
            (bind "${mod} + 8" (mvws "8"))
            (bind "${mod} + 9" (mvws "9"))
            (bind "${mod} + 0" (mvws "10"))

            # Move current window to different workspace
            (bind "${mod} + SHIFT + 1" (mvwd "1"))
            (bind "${mod} + SHIFT + 2" (mvwd "2"))
            (bind "${mod} + SHIFT + 3" (mvwd "3"))
            (bind "${mod} + SHIFT + 4" (mvwd "4"))
            (bind "${mod} + SHIFT + 5" (mvwd "5"))
            (bind "${mod} + SHIFT + 6" (mvwd "6"))
            (bind "${mod} + SHIFT + 7" (mvwd "7"))
            (bind "${mod} + SHIFT + 8" (mvwd "8"))
            (bind "${mod} + SHIFT + 9" (mvwd "9"))
            (bind "${mod} + SHIFT + 0" (mvwd "10"))

            (bind "${mod} + mouse:272" "hl.dsp.window.drag()")
            (bind "${mod} + mouse:273" "hl.dsp.window.resize()")
            (bind "${mod} + V" "hl.dsp.window.float({})") # TODO: Check
            (bind "${mod} + C" "hl.dsp.window.close()")

            (bind "${mod} + F" (fs "maximized"))
            (bind "${mod} + T" (fs "fullscreen"))

            # Vim motions
            #(bind "${mod} + H" (focusdir "l"))
            #(bind "${mod} + L" (focusdir "r"))
            #(bind "${mod} + K" (focusdir "u"))
            #(bind "${mod} + J" (focusdir "d"))

            (bind "${mod} + left" (focusdir "l"))
            (bind "${mod} + right" (focusdir "r"))
            (bind "${mod} + up" (focusdir "u"))
            (bind "${mod} + down" (focusdir "d"))
            (bind "${mod} + SHIFT + left" (movedir "l"))
            (bind "${mod} + SHIFT + right" (movedir "r"))
            (bind "${mod} + SHIFT + up" (movedir "u"))
            (bind "${mod} + SHIFT + down" (movedir "d"))

            #{
            #  _args = [
            #    "${mod} + SHIFT + LEFT"
            #    (lib.generators.mkLuaInline "hl.dsp.workspace.move({direction = \"d\"})")
            #    {description = "Move focus down";}
            #  ];
            #}

            # Audio controls
            # NOTE: Close spotify to control mpd

            #(bind "XF86AudioPlay" (exec "playerctl -p spotify,mpd play-pause"))
            #(bind "XF86AudioNext" (exec "playerctl -p spotify,mpd next"))
            #(bind "XF86AudioPrev" (exec "playerctl -p spotify,mpd previous"))

            #(bind "XF86AudioRaiseVolume" (exec "playerctl -p spotify,mpd volume 0.05+"))
            #(bind "XF86AudioLowerVolume" (exec "playerctl -p spotify,mpd volume 0.05-"))

            # Testing: Get information about currently selected window
            (bind "${mod} + I" (exec "notify-send \\\"Active window:\\\" \\\"`hyprctl activewindow`\\\""))
          ];
        };
      };
    };
  };
}
