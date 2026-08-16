{den, ...}: {
  den.aspects.email = {
    homeManager = {pkgs, ...}: {
      services.protonmail-bridge.enable = true;

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
