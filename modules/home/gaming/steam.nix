{config, pkgs, lib, ...}:
{
  options = {
    modules.gaming.steam.enable = lib.mkEnableOption "Steam setup";
  };
  config = lib.mkIf config.modules.gaming.steam.enable {
    
    programs.steam = {
      enable = true;
    };

    # Proton für Windows-Spiele
    protontricksSupport = true;

  };
}