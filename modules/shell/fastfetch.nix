{den, ...}: {
  den.aspects.shell.provides.fastfetch = {
    homeManager = {
      pkgs,
      config,
      ...
    }: {
      programs.fastfetch = {
        enable = true;
        settings = {
          logo = {
            padding = {
              top = 1;
              left = 2;
            };
          };
          display = {
            separator = "  ";
          };
          modules = [
            "title"
            "separator"
            "os"
            "kernel"
            "uptime"
            "packages"
            "shell"
            #"de"
            "wm"
            "terminal"
            "cpu"
            "gpu"
            "memory"
            "disk"
            "break"
            "colors"
          ];
        };
      };
    };
  };
}
