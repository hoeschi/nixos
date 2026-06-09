{config, pkgs, lib, ...}:
{
  options = {
    modules.development.claude.enable = lib.mkEnableOption "Claude setup";
  };
  config = lib.mkIf config.modules.development.claude.enable {
    
    nixpkgs.overlays = [ inputs.claude-code.overlays.default ];

    home.packages = with pkgs; [
      claude-code
    ];

  
  };
}