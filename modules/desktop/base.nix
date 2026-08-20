{den, ...}: {
  den.aspects.gui.provides.wayland-base = {
    includes = [
      den.aspects.shell.provides.kitty
    ];

    homeManager = {pkgs, ...}: {
      home.packages = with pkgs; [
        libnotify

        grim
        slurp

        wl-clipboard # for Screenshot functionality

        playerctl
      ];

      services.playerctld.enable = true;
    };
  };
}
