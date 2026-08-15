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

    homeManager = {pkgs, ...}:{
      home.packages = with pkgs; [
        platformio-core
        avrdude
        clang-tools
      ];

      programs.vscode = {
        
        enable = true;
        profiles.default = {
          extensions = with pkgs.vscode-extensions; [
            ms-python.python
            ms-azuretools.vscode-containers
            shd101wyy.markdown-preview-enhanced	
            llvm-vs-code-extensions.vscode-clangd
            # platformio.platformio-vscode-ide # doesnt work
            #ms-toolsai.jupyter
            #ms-vscode.cpptools
            #ms-vscode.cmake-tools
            #ms-vscode.cpptools-extension-pack
            #ms-vscode.cpptools-themes
            #ms-vscode.cmake-tools-extension-pack
            #ms-vscode.cmake-tools-themes
          ];
          userSettings = {
            "editor.fontSize" = 14;
            "editor.tabSize" = 4;
            "editor.insertSpaces" = true;
            "editor.detectIndentation" = false;
            "files.autoSave" = "afterDelay";
            "files.autoSaveDelay" = 1000;
          };
        };
      };
    };

  };

}