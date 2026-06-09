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

  #home.enableNixpkgsReleaseCheck = false; # use if unmatched nixopkgs and home manager versions

  #nixpkgs = {
  #  overlays = [
  #    inputs.nur.overlays.default
  #  ];
  #  config = {
  #    allowUnfree = true;
  #  };
  #};

  home.packages = with pkgs; [

    eza

  ];

  home.sessionPath = [
    "$HOME/.local/bin"
  ];


  #enable Modules
  modules = {
    browser.firefox.enable = true;

    desktop.kdeplasma.enable = true;
    desktop.thunderbird.enable = true;

    development = {
      vscode.enable = true;
      docker.enable = false;
      claude.enable = true;
    };

    terminal = {
      kitty.enable = true;
    };
    
    gaming.enable = true;
  };

}
