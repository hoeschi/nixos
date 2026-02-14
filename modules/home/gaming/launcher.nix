{config, pkgs, lib, ...}:
{
  options = {

    modules.gaming.steam.enable = lib.mkEnableOption "Steam setup";
    modules.gaming.heroic.enable = lib.mkEnableOption "Heroic setup";
    
  };
    

  config = lib.mkIf config.modules.gaming.steam.enable {
    
    home.packages = with pkgs; [
      steam
    ];

  };

  #config = lib.mkIf config.modules.gaming.heroic.enable {



  #};


}