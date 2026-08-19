{den, ...}: {
  den.aspects.gui.provides.hyprland-shell-noctalia = {
    includes = [
      den.aspects.gui.provides.hyprland
      den.aspects.gui.provides.noctalia
    ];

    homeManager = {pkgs, ...}: {
      home.packages = with pkgs; [
        (writeShellScriptBin "menu-launcher" "exec noctalia msg panel-toggle launcher")
        (writeShellScriptBin "menu-clipboard" "exec noctalia msg panel-toggle clipboard")
      ];
    };
  };
}
