{den, ...}: {
  den.aspects.shell.provides.kitty = {
    includes = [den.aspects.gui.provides.theming];

    homeManager = {
      config,
      lib,
      ...
    }: {
      stylix.targets.kitty.enable = config.theming.colorSource == "stylix";

      programs.kitty = {
        enable = true;

        extraConfig = lib.mkIf (config.theming.colorSource == "wallpaper") ''
          include themes/noctalia.conf
        '';

        shellIntegration = {
          #mode = "no-cursor";
          enableZshIntegration = true; # config.programs.zsh.enable;
        };

        settings = {
          cursor_shape = "beam";

          cursor_blink_interval = 0.5;
          cursor_stop_blinking_after = 15.0;

          scrollback_lines = 2000;
          scrollback_pager = "less +G -R";
          wheel_scroll_multiplier = 5.0;

          click_interval = 0.5;
          select_by_word_characters = ":@-./_~?&=%+#";
          mouse_hide_wait = 0.0;
          enabled_layouts = "*";

          remember_window_size = true;
          #initial_window_width = 640;
          #initial_window_height = 400;

          repaint_delay = 10;
          input_delay = 3;

          visual_bell_duration = 0.0;
          enable_audio_bell = false;

          open_url_modifiers = "ctrl+shift";
          open_url_with = "default";

          term = "xterm-kitty";

          window_border_width = 0;
          window_margin_width = 15;

          hide_window_decorations = "titlebar-only";
          macos_option_as_alt = false;
          macos_titlebar_color = "background";

          # Cursor trail
          cursor_trail = 3;
          cursor_trail_decay = "0.01 0.05";

          confirm_os_window_close = 0;
        };
      };
    };
  };
}
