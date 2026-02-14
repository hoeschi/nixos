{config, pkgs, lib, ...}:
{
  options = {

    modules.gaming.enable = lib.mkEnableOption "Gaming setup";
    
  };
    

  config = lib.mkIf config.modules.gaming.enable {
    
    home.packages = with pkgs; [
      steam
    ];

    programs.prismlauncher.enable = true;

  };


}