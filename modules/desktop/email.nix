{den, ...}: {
  den.aspects.email = {
    homeManager = {pkgs, ...}: {
      home.packages = with pkgs; [
        protonmail-bridge-gui
      ];
      #services.protonmail-bridge.enable = true;

      programs.thunderbird = {
        enable = true;

        profiles = {
          "default" = {
            isDefault = true;
            settings = {
            };
          };
        };
      };
    };
  };
}
