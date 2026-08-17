{den, ...}: {
  den.aspects.bhoesch = {
    includes = [
      den.batteries.define-user
      den.batteries.primary-user

      (den.batteries.user-shell "zsh")

      den.aspects.gui.provides.hyprland-shell-classic

      den.aspects.system.provides.flatpak
      den.aspects.system.provides.mounting

      den.aspects.development.provides.vscode
      den.aspects.development.provides.git
      den.aspects.development.provides.docker
      den.aspects.development.provides.ai

      den.aspects.shell.provides.zsh
      den.aspects.shell.provides.fastfetch
      den.aspects.shell.provides.kitty

      den.aspects.gaming
      den.aspects.email

      den.aspects.browser.provides.firefox
    ];

    user = {pkgs, ...}: {
      description = "Bjarne Hösch";
      uid = 1000;
      extraGroups = [
        "docker"
      ];
      packages = with pkgs; [
        kdePackages.kate
      ];
    };

    homeManager = {
      pkgs,
      config,
      ...
    }: {
      #programs.home-manager.enable = true;

      home = {
        username = "bhoesch";
        homeDirectory = "/home/bhoesch";

        stateVersion = "25.11";

        packages = with pkgs; [
          eza
        ];

        sessionVariables = {
          DOCKER_CONFIG = "${config.xdg.configHome}/docker";
          PLATFORMIO_CORE_DIR = "${config.xdg.dataHome}/platformio";
          DOTNET_CLI_HOME = "${config.xdg.dataHome}/dotnet";
          PYTHON_HISTORY = "${config.xdg.stateHome}/python_history";
          #CONDARC             = "${config.xdg.configHome}/conda/condarc";
          WGETRC = "${config.xdg.configHome}/wget/wgetrc";
        };

        sessionPath = [
          "$HOME/.local/bin"
        ];

        preferXdgDirectories = true;
      };

      xdg = {
        enable = true;

        userDirs = {
          enable = true;
          createDirectories = true;
          setSessionVariables = true;

          desktop = "${config.home.homeDirectory}/Desktop";
          download = "${config.home.homeDirectory}/Downloads";
          documents = "${config.home.homeDirectory}/Dokumente";
          music = "${config.home.homeDirectory}/Musik";
          pictures = "${config.home.homeDirectory}/Bilder";
          videos = "${config.home.homeDirectory}/Videos";
          templates = "${config.home.homeDirectory}/Vorlagen";
          publicShare = "${config.home.homeDirectory}/Öffentlich";
        };

        configFile."wget/wgetrc".text = ''
          hsts-file = ${config.xdg.cacheHome}/wget-hsts
        '';

        configFile."conda/condarc".text = ''
          envs_dirs:
            - ${config.xdg.dataHome}/conda/envs
          pkgs_dirs:
            - ${config.xdg.cacheHome}/conda/pkgs
        '';
      };
    };
  };
}
