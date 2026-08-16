# modules/desktop/theming/stylix.nix
{
  den,
  inputs,
  ...
}: {
  den.aspects.gui.provides.stylix = {
    homeManager = {pkgs, ...}: {
      imports = [inputs.stylix.homeModules.stylix];

      stylix = {
        enable = true;

        # Passt zu dem, was du aktuell in kitty.nix hardcodiert hast
        base16Scheme = "${pkgs.base16-schemes}/share/themes/tokyo-night-dark.yaml";

        fonts = {
          monospace = {
            package = pkgs.nerd-fonts.hack;
            name = "Hack Nerd Font Mono";
          };
          # serif/sansSerif bleiben auf DejaVu-Default, bis du was Eigenes willst
        };

        cursor = {
          package = pkgs.bibata-cursors;
          name = "Bibata-Modern-Ice";
          size = 24;
        };

        opacity.terminal = 0.9;

        targets = {
          kde.enable = false; # siehe unten
        };
      };
    };
  };
}
