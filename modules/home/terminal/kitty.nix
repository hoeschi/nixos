{config, lib, pkgs, ...}:

{
  options.modules.development.kitty.enable = lib.mkEnableOption "Kitty terminal";

  config = lib.mkIf config.modules.development.kitty.enable {

    programs.kitty = {

      enable = true;

      settings = {
        foreground = "#a9b1d6";
        background = "#1a1b26";

        selection_foreground = "none";
        selection_background = "#28344a";

        cursor_shape = "beam";

        cursor_blink_interval = 0.5;
        cursor_stop_blinking_after = 15.0;

        scrollback_lines = 2000;
        scrollback_pager = "less +G -R";
        wheel_scroll_multiplier = 5.0;

        click_intreval = 0.5;
        select_by_word_characters = ":@-./_~?&=%+#";
        mouse_hide_wait = 0.0;
        enabled_layouts = "*";

        remember_window_size = false;
        initial_window_width = 640;
        initial_window_height = 400;

        repaint_delay = 10;
        input_delay = 3;

        visual_bell_duration = 0.0;
        enable_audio_bell = false;

        open_url_modifiers = "ctrl+shift";
        open_url_with = "default";

        term = "xterm-kitty";

        window_border_width = 0;
        window_margin_width = 15;

        active_border_color = "#3d59a1";
        inactive_border_color = "#101014";

        active_tab_foreground = "#000";
        active_tab_background = "#eee";
        inactive_tab_foreground = "#444";
        inactive_tab_background = "#999";

        cursor = "#c0caf5";

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
}