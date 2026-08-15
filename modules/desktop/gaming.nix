{den, ...}:
{

  den.aspects.gaming = {

    nixos = {pkgs, ...}:{
      programs = {
        gamescope.enable = true;
        gamemode.enable = true;

        steam = {
          enable = true;
          package = pkgs.steam.override {
            extraEnv = {
              MANGOHUD = true;
            };
          };
        };
      };

      environment.systemPackages = with pkgs; [
        (discord.override {
            withOpenASAR = true;
            withVencord = true;
        })
      ];

    };

    homeManager = {pkgs, ...}:
    {
      home.packages = with pkgs; [
        #steam
        steam-run
        #lutris

        protonup-qt

        ryubing # Switch emulator

        (heroic.override {
          extraPkgs = pkgs': with pkgs'; [
            gamescope
            gamemode
          ];
        })
      ];

      programs = {
        prismlauncher.enable = true;
        mangohud = {
          enable = true;
          settings = {
            toggle_hud = "F10";
            gpu_temp = true;
            cpu_temp = true;
            no_display = true;
          };
        };
      };
    };
  };
}