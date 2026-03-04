{config, inputs, pkgs, ...}:

{

  imports = [
    ../../modules/home
  ];

  programs.home-manager.enable = true;

  home = {
    username = "bhoesch";
    homeDirectory = "/home/bhoesch";

    stateVersion = "25.11";
  };

  nixpkgs = {
    overlays = [
      inputs.nur.overlays.default
    ];
    config = {
      allowUnfree = true;
    };
  };

  home.packages = with pkgs; [

    eza

  ];

  #enable Modules
  modules = {
    browser.firefox.enable = true;

    desktop.kdeplasma.enable = true;
    desktop.thunderbird.enable = true;

    development = {
      vscode.enable = true;
    };

    terminal = {
      kitty.enable = true;
    };
    
    gaming.enable = true;
  };

}
