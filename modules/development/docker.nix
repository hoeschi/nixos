{den, ...}: {
  den.aspects.development.provides.docker = {
    nixos = {
      virtualisation.docker.enable = true; # Docker-Daemon

      # Container dürfen Dienste auf dem Host erreichen (z.B. openssh auf 172.17.0.1)
      networking.firewall.trustedInterfaces = ["docker0"];
    };

    homeManager = {
      pkgs,
      config,
      ...
    }: {
      home.packages = with pkgs; [
        docker
        docker-compose
      ];

      home.sessionVariables.DOCKER_CONFIG = "${config.xdg.configHome}/docker";

      programs.lazydocker = {
        enable = true;
      };
    };
  };
}
