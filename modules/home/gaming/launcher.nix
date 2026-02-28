{config, pkgs, lib, ...}:

{
  options = {

    modules.gaming.enable = lib.mkEnableOption "Gaming setup";
    
  };
    

  config = lib.mkIf config.modules.gaming.enable {

    home.packages = with pkgs; [
      steam
      lutris

      protonup-qt

      (heroic.override {
        extraPkgs = pkgs': with pkgs'; [
          gamescope
          gamemode
        ];
      })

    ];

    programs.prismlauncher.enable = true;

  };


}