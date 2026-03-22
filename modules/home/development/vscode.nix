{config, pkgs, lib, ...}:
{
  options = {
    modules.development.vscode.enable = lib.mkEnableOption "VSCode setup";
  };
  config = lib.mkIf config.modules.development.vscode.enable {

    home.packages = with pkgs; [
      platformio-core
      avrdude
    ];

    programs.vscode = {
      
      enable = true;
      profiles.default = {
        extensions = with pkgs.vscode-extensions; [
          ms-python.python
          ms-azuretools.vscode-containers
	        shd101wyy.markdown-preview-enhanced	
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
}
