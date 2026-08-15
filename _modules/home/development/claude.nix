{config, pkgs, lib, ...}:
{
  options = {
    modules.development.claude.enable = lib.mkEnableOption "Claude setup";
  };
  config = lib.mkIf config.modules.development.claude.enable {

    home.packages = with pkgs; [
      claude-code
    ];

  
  };
}