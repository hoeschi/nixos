{den, ...}: {
  den.aspects.gaming = {
    nixos = {pkgs, ...}: {
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
          # OpenASAR hangs on startup with Discord 1.0.168 (no window ever appears)
          #withOpenASAR = true;
          withVencord = true;
        })

        xivlauncher
        clonehero

        # Windows-Spiele/-Programme außerhalb von Steam
        wineWow64Packages.stable
        winetricks
        protontricks
        #bottles

        libstrangle # FPS-Limiter (strangle)
        vulkan-tools # vulkaninfo, vkcube
      ];
    };

    homeManager = {pkgs, ...}: {
      home.packages = with pkgs; [
        #steam
        steam-run
        #lutris

        chiaki-ng # for Playstation remote play

        protonup-qt

        ryubing # Switch emulator

        (heroic.override {
          extraPkgs = pkgs':
            with pkgs'; [
              gamescope
              gamemode
            ];
        })
      ];

      programs = {
        prismlauncher.enable = true;
        lutris.enable = true;
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
