{config, inputs, pkgs, ...}:

{
  imports = [
    ../../modules/home
  ];
  home = {
    username = "bhoesch";
    homeDirectory = "/home/bhoesch";

    stateVersion = "25.11";
  };

  #enable Modules
  modules = {
    browser.firefox.enable = true;
    desktop.kdeplasma.enable = true;
  };

}