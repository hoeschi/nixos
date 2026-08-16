{den, ...}: {
  den.aspects.browser.provides.firefox = {
    homeManager = {pkgs, ...}: {
      programs.firefox = {
        enable = true;
        configPath = ".mozilla/firefox";

        profiles.default = {
          # Konfiguration
          extensions.packages = with pkgs.nur.repos.rycee.firefox-addons; [
            ublock-origin
            onepassword-password-manager
            darkreader
            seventv
            #new-tab-override
          ];
        };
      };

      stylix.targets = {
        #firefox.profileNames = lib.attrNames (config.programs.firefox.profiles or {});
        firefox.profileNames = ["default"];
      };
    };
  };
}
