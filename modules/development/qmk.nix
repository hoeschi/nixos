{den, ...}: {
  den.aspects.development.provides.qmk = {
    nixos = {pkgs, ...}: {
      hardware.keyboard.qmk.enable = true;
      users.extraGroups = ["plugdev" "dialout"];

      environment.systemPackages = with pkgs; [
        qmk
      ];
    };
  };
}
