# modules/desktop/theming/stylix.nix
{
  den,
  inputs,
  ...
}: {
  den.aspects.gui.provides.stylix = {
    nixos = {
      pkgs,
      lib,
      ...
    }: {
      imports = [inputs.stylix.nixosModules.stylix];

      stylix = {
        enable = true;

        # Passt zu dem, was du aktuell in kitty.nix hardcodiert hast
        base16Scheme = "${pkgs.base16-schemes}/share/themes/tokyo-night-dark.yaml";
        polarity = "dark";

        fonts = {
          monospace = {
            package = pkgs.nerd-fonts.hack;
            name = "Hack Nerd Font Mono";
          };

          # for dunst
          sansSerif = {
            package = pkgs.inter;
            name = "Inter";
          };

          sizes = {
            # terminal = 10.5; # → 14 px im Editor, entspricht deinem alten Wert
            applications = 10;
            terminal = 11;
            popups = 11;
          };
        };

        opacity.popups = 0.9;

        cursor = {
          package = pkgs.bibata-cursors;
          name = "Bibata-Modern-Ice";
          size = 24;
        };

        targets = {
          #kde.enable = false; # siehe unten
          #firefox.profileNames = ["default"];
          qt.platform = lib.mkForce "qtct";
        };
      };
    };
  };
}
