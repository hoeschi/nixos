{den, ...}:
{

  den.aspects.development.provides.vscode = {

    nixos = {pkgs, ...}:{
      services.udev.packages = with pkgs; [
        platformio-core.udev
        openocd
      ];

      programs.nix-ld = {
        enable = true;
    
        # Ggf. zusätzliche Libs für den ARM-Toolchain
        libraries = with pkgs; [
            stdenv.cc.cc.lib
            zlib
            libusb1
            libxcb
            icu

            fontconfig
            freetype
            libGL
            libX11
            libXext
            libICE
            libSM
            libXi
            libXrender
            libXrandr
            libXcursor
            libXinerama
            libxkbcommon

            gnutls
        ];
      };

    };

  };

}