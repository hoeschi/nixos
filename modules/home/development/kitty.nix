{config, lib, pkgs, ...}:

{
  options.modules.development.kitty.enable = lib.mkEnableOption "Kitty terminal";


}