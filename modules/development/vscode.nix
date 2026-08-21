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
      lib,
      ...
    }: let
      # Muss zum output_path des Community-Templates passen:
      # ~/.vscode/extensions/noctalia.noctaliatheme-0.0.5/themes/…
      # Abgleich bei Problemen:
      # ~/.local/state/noctalia/community-templates/vscode/template.toml
      noctaliaThemeVersion = "0.0.5";

      noctaliaTheme = pkgs.vscode-utils.extensionFromVscodeMarketplace {
        name = "noctaliatheme";
        publisher = "noctalia";
        version = noctaliaThemeVersion;
        sha256 = "sha256-aTSk3yYkBw5GrD0CbRL2wo3SlBffzBTDe1pZoZa1URQ=";
      };

      extDir = "${config.home.homeDirectory}/.vscode/extensions/noctalia.noctaliatheme-${noctaliaThemeVersion}";
    in {
      stylix.targets.vscode.enable = config.theming.colorSource == "stylix";

      home.packages = with pkgs; [
        platformio-core
        avrdude
        clang-tools
      ];

      # Die Extension läuft bewusst nicht über profiles.default.extensions:
      # das Noctalia-Template schreibt sein Ergebnis in das Extension-
      # Verzeichnis selbst, was bei einem Store-Symlink fehlschlägt. Zudem
      # erwartet es den Namen mit Versionssuffix, den HM nicht vergibt.
      # Deshalb eine beschreibbare Kopie unter dem passenden Namen.
      home.activation.noctaliaVscodeTheme =
        lib.hm.dag.entryAfter ["writeBoundary"]
        (lib.optionalString (config.theming.colorSource == "wallpaper") ''
          run rm -rf ${lib.escapeShellArg extDir}
          run mkdir -p ${lib.escapeShellArg extDir}
          run cp -rT ${noctaliaTheme}/share/vscode/extensions/noctalia.noctaliatheme ${lib.escapeShellArg extDir}
          run chmod -R u+w ${lib.escapeShellArg extDir}
        '');

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
