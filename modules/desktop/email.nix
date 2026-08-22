{den, ...}: {
  den.aspects.email = {
    homeManager = {pkgs, ...}: {
      home.packages = with pkgs; [
        protonmail-bridge-gui
      ];
      #services.protonmail-bridge.enable = true;

      systemd.user.services.protonmail-bridge-gui = {
        Unit = {
          Description = "Proton Mail Bridge";
          PartOf = ["graphical-session.target"];
          After = ["graphical-session.target"];
        };
        Service = {
          ExecStart = "${pkgs.protonmail-bridge-gui}/bin/protonmail-bridge-gui --no-window";
        };
        Install.WantedBy = ["graphical-session.target"];
      };

      programs.thunderbird = {
        enable = true;

        profiles = {
          "default" = {
            isDefault = true;
            settings = {
            };
          };
        };
      };
    };
  };
}
