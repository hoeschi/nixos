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

        fonts = {
          monospace = {
            package = pkgs.nerd-fonts.hack;
            name = "Hack Nerd Font Mono";
          };
          # serif/sansSerif bleiben auf DejaVu-Default, bis du was Eigenes willst

          sizes = {
            # terminal = 10.5; # → 14 px im Editor, entspricht deinem alten Wert
            applications = 10;
            terminal = 11;
          };
        };

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
