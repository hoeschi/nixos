{
  den,
  lib,
  ...
}: {
  den.aspects.gui.provides.hyprshell = {
    homeManager = {config, ...}: {
      services.hyprshell = {
        enable = true;

        settings = {
          version = 4;
          windows = {
            scale = 8.0;
            items_per_row = 5;
            overview = {
              key = "tab";
              modifier = "super";
              filter_by = [];
            };
            switch = {
              modifier = "alt";
              filter_by = [];
              switch_workspaces = false; # switch apps instead of workspaces
            };
          };
        };

        style = let
          c = config.lib.stylix.colors.withHashtag;
        in ''
          :root {
            --bg-color: ${c.base00};
            --bg-color-hover: ${c.base02};
            --border-color: ${c.base03};
            --border-color-active: ${c.base0D};
            --index-border-color: ${c.base0D};
            --border-radius: 12px;
            --border-size: 2px;
          }
        '';
      };
    };
  };
}
