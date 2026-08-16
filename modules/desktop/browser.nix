{den, ...}: {
  den.aspects.browser.provides.firefox = {
    homeManager = {pkgs, ...}: {
      programs.firefox = {
        enable = true;
        configPath = ".mozilla/firefox";

        profiles.default = {
          # Konfiguration
          extensions = {
            packages = with pkgs.nur.repos.rycee.firefox-addons; [
              ublock-origin
              onepassword-password-manager
              darkreader
              seventv
              #new-tab-override
            ];

            # Stylix schreibt hier das Firefox-Color-Theme rein
            settings."FirefoxColor@mozilla.com".force = true;
          };
        };
      };

      stylix.targets.firefox = {
        #firefox.profileNames = lib.attrNames (config.programs.firefox.profiles or {});
        profileNames = ["default"];
        colorTheme.enable = true;
      };
    };
  };
}
