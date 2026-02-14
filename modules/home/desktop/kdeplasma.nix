{config, lib, pkgs, ...}:

{
  options.modules.desktop.kdeplasma.enable = lib.mkEnableOption "KDE Plasma desktop environment";


}
