{den, ...}: {
  den.aspects.development.provides.qmk = {
    nixos = {pkgs, ...}: {
      hardware.keyboard.qmk.enable = true;

      environment.systemPackages = with pkgs; [
        qmk
        dos2unix
      ];
    };
  };
}
