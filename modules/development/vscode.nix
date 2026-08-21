{
  den,
  lib,
  ...
}: {
  den.aspects.development.provides.vscode = {
    nixos = {
      pkgs,
      config,
      ...
    }: {
      services.udev.packages = with pkgs; [
        platformio-core.udev
        openocd
      ];

      environment.sessionVariables = {
        COPILOT_HOME = "$HOME/.config/copilot"; # undokumentiert, kann per VSCode-Update wegfallen
      };

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

    homeManager = {
      pkgs,
      config,
      ...
    }: {
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
            kamadorueda.alejandra
            # platformio.platformio-vscode-ide # doesnt work
            #ms-toolsai.jupyter
            #ms-vscode.cpptools
            #ms-vscode.cmake-tools
            #ms-vscode.cpptools-extension-pack
            #ms-vscode.cpptools-themes
            #ms-vscode.cmake-tools-extension-pack
            #ms-vscode.cmake-tools-themes
          ];
          #++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [
          # {
          #  name = "noctaliatheme";
          # publisher = "noctalia";
          #version = "0.0.5";
          #sha256 = "sha256-aTSk3yYkBw5GrD0CbRL2wo3SlBffzBTDe1pZoZa1URQ=";
          #}
          #];
          userSettings = lib.mkMerge [
            {
              #"editor.fontSize" = 14; # conflicts with stylix
              "editor.tabSize" = 4;
              "editor.insertSpaces" = true;
              "editor.detectIndentation" = false;
              "files.autoSave" = "afterDelay";
              "files.autoSaveDelay" = 1000;

              "workbench.tree.indent" = 20;
              "workbench.tree.renderIndentGuides" = "always";
            }

            (lib.mkIf (config.theming.colorSource == "wallpaper") {
              "workbench.colorTheme" = "NoctaliaTheme";
              "editor.fontFamily" = config.stylix.fonts.monospace.name;
              "editor.fontSize" = config.stylix.fonts.sizes.terminal * 4.0 / 3;
            })
          ];
        };
      };
    };
  };
}
