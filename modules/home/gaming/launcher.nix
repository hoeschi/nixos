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

      ryubing # Switch emulator

      (heroic.override {
        extraPkgs = pkgs': with pkgs'; [
          gamescope
          gamemode
        ];
      })

    ];

    programs.prismlauncher.enable = true;

    programs.mangohud = {
      enable = true;
      settings = {
        toggle_hud = "F10";
        gpu_temp = true;
        cpu_temp = true;
        no_display = true;
      };
    };

  };


}