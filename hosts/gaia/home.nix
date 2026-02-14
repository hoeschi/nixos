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

  #enable Modules
  modules = {
    browser.firefox.enable = true;
    desktop.kdeplasma.enable = true;
    development.vscode.enable = true;
    gaming.steam.enable = true;
  };

}
