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
        base16Scheme = "${pkgs.base16-schemes}/share/themes/catppuccin-mocha.yaml";
        #catppuccin-mocha
        #tokyo-night-dark
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
            applications = 11;
            terminal = 11;
            popups = 11;
          };
        };

        opacity = {
          #popups = 0.9;
          #applications = 0.9;
        };

        cursor = {
          package = pkgs.bibata-cursors;
          name = "Bibata-Modern-Ice";
          size = 24;
        };

        autoEnable = false;

        targets = {
          console.enable = true;
          fontconfig.enable = true;
          font-packages.enable = true;
          grub.enable = true;

          qt.enable = true;
          qt.platform = lib.mkForce "qtct";
        };
      };

      # autoEnable vererbt sich nicht zuverlässig in die HM-Konfiguration,
      # deshalb hier explizit. fontconfig/font-packages existieren auf beiden
      # Ebenen und werden auf beiden gebraucht.
      home-manager.sharedModules = [
        {
          stylix.autoEnable = false;

          stylix.targets = {
            fontconfig.enable = true;
            font-packages.enable = true;
          };
        }
      ];
    };
  };
}
