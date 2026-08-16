{den, ...}: {
  den.aspects.gui.provides.hyprland = {
    services.dunst = {
      enable = true;
      settings = {
        global = {
          width = 300;
          height = "(100,500)";
          offset = "(30,50)";
          origin = "top-right";
          transparency = 10;
          # frame_color = "#${config.lib.stylix.colors.base03}";
        };

        urgency_normal = {
          # background = "#${config.lib.stylix.colors.base00}";
          # foreground = "#${config.lib.stylix.colors.base05}";
          timeout = 10;
        };
      };
    };
  };
}
