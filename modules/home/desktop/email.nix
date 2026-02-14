{config, lib, pkgs, ...}:

{

options = {
    modules.desktop.proton.enable = lib.mkEnableOption "Proton setup";
  };

  config = lib.mkIf config.modules.desktop.proton.enable {

    

}