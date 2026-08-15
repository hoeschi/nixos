{config, pkgs, lib, ...}:
{
  options = {
    modules.development.docker.enable = lib.mkEnableOption "Docker setup";
  };
  config = lib.mkIf config.modules.development.docker.enable {
    
    home.packages = with pkgs; [
      docker
      docker-compose
    ];

    programs.lazydocker = {
      enable = true;
    };

    

  };
}