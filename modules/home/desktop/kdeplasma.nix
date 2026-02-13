{config, lib, pkgs, ...}:

{
  options.modules.desktop.kdeplasma.enable = lib.mkEnableOption "KDE Plasma desktop environment";

  config = lib.mkIf config.modules.desktop.kdeplasma.enable {
    services.desktopManager.plasma6.enable = true;
  
  };
}