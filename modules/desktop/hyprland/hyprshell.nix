{den, ...}: {
  den.aspects.gui.provides.hyprland = {
    homeManager = {
      services.hyprshell = {
        enable = true;
        settings = {
          windows = {
            scale = 8.0;
            items_per_row = 5;
            switch = {
              modifier = "alt";
              filter_by = [];
              switch_workspaces = false;
            };
          };
        };
      };
    };
  };
}
