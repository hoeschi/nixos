{den, ...}:
{

  den.aspects.development.provides.docker = {

    homeManager = {pkgs, config, ...}:
    {
      home.packages = with pkgs; [
        docker
        docker-compose
      ];

      programs.lazydocker = {
        enable = true;
      };
    };
  };
}