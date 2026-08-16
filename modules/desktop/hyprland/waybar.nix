# modules/desktop/hyprland/waybar.nix
{den, ...}: {
  den.aspects.gui.provides.hyprland = {
    homeManager = {
      pkgs,
      lib,
      ...
    }: let
      # NOTE: Muss zu den Monitor-Namen in hyprland.nix passen.
      #       Später ggf. gemeinsam in ein Modul auslagern.
      monitor0 = "DP-2"; # Workspaces 1, 2, 10
      monitor1 = "HDMI-A-1"; # Workspaces 3, 4, 5

      # /sys/class/hwmon/hwmonN ist NICHT stabil über Reboots hinweg
      # (Reihenfolge hängt von der Probe-Reihenfolge der Treiber ab).
      # Deshalb wird nach dem Treibernamen gesucht statt einen Pfad
      # hart zu verdrahten. temp1_input ist bei k10temp = Tctl,
      # bei amdgpu = Edge-Temperatur.
      hwmonTemp = pkgs.writeShellScript "waybar-hwmon-temp" ''
        set -eu
        want="$1"
        for h in /sys/class/hwmon/hwmon*; do
          [ -r "$h/name" ] || continue
          [ "$(cat "$h/name")" = "$want" ] || continue
          [ -r "$h/temp1_input" ] || continue
          ${pkgs.gawk}/bin/awk '{ printf "%d\n", ($1 + 500) / 1000 }' "$h/temp1_input"
          exit 0
        done
        echo "--"
      '';

      # ── Modul-Definitionen (für beide Bars identisch) ──────────────
      commonModules = {
        "hyprland/window" = {
          format = "{title}";
          max-length = 60;
          separate-outputs = true; # Titel pro Monitor, nicht global
          icon = false;
        };

        "mpris" = {
          format = "{player_icon} {dynamic}";
          format-paused = "{status_icon} <i>{dynamic}</i>";
          dynamic-order = ["title" "artist"];
          dynamic-len = 40;
          player-icons.default = "󰐊";
          status-icons.paused = "󰏤";
          on-click = "playerctld shift"; # zwischen Playern wechseln
          on-click-middle = "playerctl play-pause";
        };

        "cpu" = {
          format = "󰻠 {usage}%";
          interval = 3;
          tooltip = false;
          on-click = "kitty -e btop";
        };

        "custom/cputemp" = {
          exec = "${hwmonTemp} k10temp";
          interval = 5;
          format = "󰔏 {}°C";
          tooltip = false;
        };

        "memory" = {
          format = "󰍛 {percentage}%";
          tooltip-format = "{used:0.1f}G / {total:0.1f}G";
          interval = 5;
          on-click = "kitty -e btop";
        };

        "custom/gputemp" = {
          exec = "${hwmonTemp} amdgpu";
          interval = 5;
          format = "󰢮 {}°C";
          tooltip = false;
        };

        "pulseaudio" = {
          format = "{icon} {volume}%";
          format-muted = "󰝟 stumm";
          format-icons.default = ["󰕿" "󰖀" "󰕾"];
          scroll-step = 5;
          on-click = "pavucontrol";
          on-click-right = "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
          tooltip-format = "{desc}";
        };

        "network" = {
          format-ethernet = "󰈀 {ifname}";
          format-wifi = "󰤨 {essid}";
          format-disconnected = "󰤭 offline";
          tooltip-format-ethernet = "{ifname}: {ipaddr}/{cidr}";
          tooltip-format-wifi = "{essid} ({signalStrength}%)\n{ipaddr}/{cidr}";
          on-click = "kitty -e nmtui";
        };

        "clock" = {
          format = "󰥔 {:%H:%M}";
          format-alt = "󰃭 {:%a, %d.%m.%Y}";
          tooltip-format = "<tt><small>{calendar}</small></tt>";
          calendar = {
            mode = "month";
            weeks-pos = "right";
            on-scroll = 1;
          };
          actions = {
            on-click-right = "mode"; # Monats-/Jahresansicht
            on-scroll-up = "shift_up";
            on-scroll-down = "shift_down";
          };
        };

        "tray" = {
          icon-size = 18;
          spacing = 10;
          show-passive-items = true;
        };
      };

      # ── Bar-Fabrik ────────────────────────────────────────────────
      mkBar = {
        output,
        workspaces,
        tray ? false,
      }:
        commonModules
        // {
          layer = "top";
          position = "top";
          height = 34;
          spacing = 6;
          output = [output];

          modules-left = ["hyprland/workspaces" "hyprland/window"];
          modules-center = ["clock"];
          modules-right =
            [
              "mpris"
              "cpu"
              "custom/cputemp"
              "memory"
              "custom/gputemp"
              "pulseaudio"
              "network"
            ]
            ++ lib.optional tray "tray";

          # all-outputs = false -> jede Bar zeigt nur die Workspaces
          # ihres eigenen Monitors. Passt zu den workspace_rule aus
          # hyprland.nix.
          "hyprland/workspaces" = {
            all-outputs = false;
            show-special = true;
            on-click = "activate";
            format = "{name}";
            persistent-workspaces =
              lib.genAttrs (map toString workspaces) (_: [output]);
          };
        };
    in {
      home.packages = with pkgs; [
        pavucontrol # on-click des pulseaudio-Moduls
        playerctl # liefert playerctld für das mpris-Modul
        btop # on-click von cpu/memory
      ];

      services.playerctld.enable = true;

      programs.waybar = {
        enable = true;

        systemd = {
          enable = true;
          # Analog zu copyq.nix: erst starten, wenn Hyprland seine
          # Session-Target erreicht hat. Setzt wayland.windowManager
          # .hyprland.systemd.enable = true voraus (ist gesetzt).
          target = "hyprland-session.target";
        };

        settings = {
          mainBar = mkBar {
            output = monitor0;
            workspaces = [1 2 10];
            tray = true; # Tray nur einmal -> sonst doppelte Icons
          };

          sideBar = mkBar {
            output = monitor1;
            workspaces = [3 4 5];
          };
        };

        # style bewusst nicht gesetzt: Farben, Font und Größen kommen
        # von Stylix (stylix.targets.waybar, per Default aktiv).
      };
    };
  };
}
