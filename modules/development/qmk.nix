{
  den,
  inputs,
  ...
}: {
  imports = [inputs.den.flakeOutputs.devShells];

  den.schema.flake-system.includes = [
    den.aspects.development.provides.qmk-shell
  ];

  den.aspects.development.provides.qmk = {
    nixos = {pkgs, ...}: {
      hardware.keyboard.qmk.enable = true;

      environment.systemPackages = with pkgs; [
        qmk
        dos2unix
      ];
    };

    homeManager = {pkgs, ...}: {
      # Gleiches Muster wie dein altes dev-shell-esp32
      home.packages = [
        (pkgs.writeShellScriptBin "dev-shell-qmk" ''
          exec nix develop "path:$HOME/nixos#qmk" -c "$SHELL" "$@"
        '')
      ];
    };
  };

  # ---------------------------------------------------------------------------
  # Build-Umgebung mit gepinnter AVR-Toolchain.
  #
  # Hintergrund: das nixpkgs-Paket `qmk` zieht über propagatedBuildInputs
  # pkgsCross.avr.buildPackages.gcc mit, aktuell avr-gcc 15. Der erzeugt für
  # ATmega32U4 rund 24% größeren Code als das von QMK getestete avr-gcc 8 —
  # genug, um dumbpad/v3x über die 28672 Bytes des Caterina-Flash zu drücken.
  # gcc8 existiert nur noch bis nixos-24.11, daher der zweite nixpkgs-Input.
  # ---------------------------------------------------------------------------
  den.aspects.development.provides.qmk-shell = {
    devShells = {pkgs, ...}: let
      avr =
        inputs.nixpkgs-avr.legacyPackages
        .${pkgs.stdenv.hostPlatform.system}
        .pkgsCross.avr;

      # CLI aus unstable (das Repo braucht platformdirs, das milc erst in
      # neueren Versionen mitbringt), AVR-Toolchain aus 24.11. Das Attribut
      # heißt dort libcCross und wurde erst später zu libc umbenannt.
      qmk-avr8 = pkgs.qmk.override {
        pkgsCross =
          pkgs.pkgsCross
          // {
            avr =
              pkgs.pkgsCross.avr
              // {
                libc = avr.libcCross;
                buildPackages =
                  pkgs.pkgsCross.avr.buildPackages
                  // {
                    gcc = avr.buildPackages.gcc8;
                    binutils = avr.buildPackages.binutils;
                  };
              };
          };
      };
    in {
      qmk = pkgs.mkShell {
        packages =
          [qmk-avr8]
          ++ (with pkgs; [
            git
            gnumake
            python3
            avrdude
            dos2unix
          ]);

        shellHook = ''
          echo "QMK-Shell — avr-gcc $(avr-gcc -dumpversion)"
        '';
      };
    };
  };
}
