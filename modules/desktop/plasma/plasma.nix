{den, ...}: {
  den.aspects.gui.provides.plasma = {
    nixos = {pkgs, ...}: {
      services.desktopManager.plasma6.enable = true;

      environment.systemPackages = with pkgs; [
        kdePackages.plasma-browser-integration
        kdePackages.kwallet
        kdePackages.kclock
      ];

      xdg.portal = {
        enable = true;
        extraPortals = with pkgs; [
          kdePackages.xdg-desktop-portal-kde
        ];
      };
    };

    homeManager = {...}: {
      stylix.targets = {
        #kde.enable = false;
      };
    };
  };
}
