{den, ...}: {
  den.aspects.gui.provides.classic-shell = {
    includes = [
      den.aspects.gui.provides.waybar
      den.aspects.gui.provides.dunst
      den.aspects.gui.provides.copyq
      den.aspects.gui.provides.hyprshell
    ];

    homeManager = {pkgs, ...}: {
      home.packages = with pkgs; [
        rofi # programm starter | rofi-wayland merged into rofi
        awww # wallpaper demon

        (writeShellScriptBin "menu-launcher" "exec rofi -show drun")
        (writeShellScriptBin "menu-clipboard" "exec copyq menu")
      ];
    };
  };
}
