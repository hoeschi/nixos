{ inputs, config, pkgs, lib, ... }:
{
  options = {
    modules.browser.firefox.enable = lib.mkEnableOption "Firefox setup";
  };

  config = lib.mkIf config.modules.browser.firefox.enable {

    programs.firefox.enable = true;

    programs.firefox.profiles.default = {
      # Konfiguration
      extensions.packages = with pkgs.nur.repos.rycee.firefox-addons; [
        ublock-origin
        onepassword-password-manager
      ];

    };
  };
}
