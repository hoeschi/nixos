{config, lib, pkgs, ...}:

{

options = {
    modules.desktop.thunderbird.enable = lib.mkEnableOption "Thunderbird setup";
  };

  config = lib.mkIf config.modules.desktop.thunderbird.enable {

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
}
