{den, ...}: {
  den.aspects.gui.provides.hyprland = {
    homeManager = {
      pkgs,
      config,
      ...
    }: {
      # Layout (Rundungen, Abstände) lässt sich mit Stylix' Waybar-Target
      # nicht ausdrücken. Farben und Schrift kommen trotzdem aus Stylix,
      # siehe den @define-color-Block bei style unten.
      stylix.targets.waybar.enable = false;

      # playerctl liefert playerctld, das mpris-Modul braucht es.
      home.packages = [pkgs.playerctl];
      services.playerctld.enable = true;

      programs.waybar = {
        enable = true;

        systemd = {
          enable = true;
          # Analog zu copyq.nix: erst starten, wenn Hyprland seine
          # Session-Target erreicht hat.
          target = "hyprland-session.target";
        };

        settings.bar = {
          layer = "top";
          position = "top";
          height = 34;
          spacing = 4;

          # Schwebende Leiste, passend zu gaps_out = 10 in hyprland.nix
          margin-top = 8;
          margin-left = 12;
          margin-right = 12;
          margin-bottom = 0;

          modules-left = ["mpris"];
          modules-center = ["hyprland/workspaces"];
          modules-right = [
            "cpu"
            "custom/cputemp"
            "memory"
            "custom/gputemp"
            "pulseaudio"
            "network"
            "clock"
            "tray"
            "custom/power"
          ];

          "hyprland/workspaces" = {
            all-outputs = false; # jede Bar nur die Workspaces ihres Monitors
            active-only = false;
            show-special = true;
            format = "{name}";
            on-click = "activate";
            on-scroll-up = "hyprctl dispatch workspace e-1";
            on-scroll-down = "hyprctl dispatch workspace e+1";

            # Muss zu den workspace_rule in hyprland.nix passen
            persistent-workspaces = {
              "1" = ["DP-2"];
              "2" = ["DP-2"];
              "10" = ["DP-2"];
              "3" = ["HDMI-A-1"];
              "4" = ["HDMI-A-1"];
              "5" = ["HDMI-A-1"];
            };
          };

          mpris = {
            format = "{player_icon} {dynamic}";
            format-paused = "{status_icon} <i>{dynamic}</i>";
            dynamic-order = ["title" "artist"];
            dynamic-len = 40;
            player-icons.default = "󰐊";
            status-icons.paused = "󰏤";
            on-click = "playerctl play-pause";
          };

          cpu = {
            format = "󰻠 {usage}%";
            format-alt = "󰻠 {load}";
            interval = 3;
            tooltip = false;
          };

          "custom/cputemp" = {
            exec = "${pkgs.bash}/bin/bash ${./hwmon-temp.sh} k10temp 70 85";
            return-type = "json";
            interval = 5;
            format = "󰔏 {}°C";
            tooltip = false;
          };

          memory = {
            format = "󰍛 {percentage}%";
            format-alt = "󰍛 {used:0.1f}G";
            tooltip-format = "{used:0.1f}G von {total:0.1f}G belegt";
            interval = 5;
          };

          "custom/gputemp" = {
            exec = "${pkgs.bash}/bin/bash ${./hwmon-temp.sh} amdgpu 75 90";
            return-type = "json";
            interval = 5;
            format = "󰢮 {}°C";
            tooltip = false;
          };

          pulseaudio = {
            format = "{icon} {volume}%";
            format-bluetooth = "{icon}󰂯 {volume}%";
            format-muted = "󰝟 stumm";
            format-icons = {
              headphone = "󰋋";
              headset = "󰋎";
              portable = "󰦧";
              car = "󰄋";
              default = ["󰕿" "󰖀" "󰕾"];
            };
            tooltip-format = "{desc}";
            scroll-step = 5;
            # wpctl kommt mit wireplumber, ist durch services.pipewire da
            on-click = "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
          };

          network = {
            format-ethernet = "󰈀 {ipaddr}";
            format-wifi = "󰤨 {essid} ({signalStrength}%)";
            format-linked = "󰈀 {ifname} (keine IP)";
            format-disconnected = "󰤭 offline";
            format-alt = "󰇚 {bandwidthDownBits}  󰕒 {bandwidthUpBits}";
            tooltip-format = "{ifname} über {gwaddr}";
            interval = 5;
          };

          clock = {
            interval = 30;
            format = "{:%H:%M  %d.%m.%Y}";
            tooltip-format = "<tt><small>{calendar}</small></tt>";
            calendar.mode = "month";
          };

          tray = {
            icon-size = 18;
            spacing = 10;
            show-passive-items = true;
          };

          "custom/power" = {
            format = "󰐥";
            tooltip = false;
            menu = "on-click";
            menu-file = "${./power-menu.xml}";
            menu-actions = {
              lock = "loginctl lock-session";
              logout = "hyprctl dispatch exit";
              suspend = "systemctl suspend";
              reboot = "systemctl reboot";
              shutdown = "systemctl poweroff";
            };
          };
        };

        # Farben und Schrift aus Stylix vorne reinschreiben, der Rest
        # steht in waybar.css und arbeitet nur noch mit @base0X.
        style = with config.lib.stylix.colors.withHashtag; ''
          @define-color base00 ${base00};
          @define-color base01 ${base01};
          @define-color base02 ${base02};
          @define-color base03 ${base03};
          @define-color base04 ${base04};
          @define-color base05 ${base05};
          @define-color base08 ${base08};
          @define-color base0A ${base0A};
          @define-color base0D ${base0D};
          @define-color base0E ${base0E};

          * { font-family: "${config.stylix.fonts.monospace.name}"; }

          ${builtins.readFile ./waybar.css}
        '';
      };
    };
  };
}
