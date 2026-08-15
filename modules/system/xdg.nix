{ config, ... }:
{
  # XDG Base Directory Specification – systemweit für alle Sessions.
  # Wird via PAM (/etc/pam/environment) gesetzt, gilt also auch für
  # grafische Logins über SDDM, nicht nur für Login-Shells.
  environment.sessionVariables = {
    XDG_CACHE_HOME  = "$HOME/.cache";
    XDG_CONFIG_HOME = "$HOME/.config";
    XDG_DATA_HOME   = "$HOME/.local/share";
    XDG_STATE_HOME  = "$HOME/.local/state";
    PLATFORMIO_CORE_DIR = "$HOME/.local/share/platformio";
    DOTNET_CLI_HOME     = "$HOME/.local/share/dotnet";

  };

  # Verzeichnisse deklarativ anlegen, statt sich darauf zu verlassen,
  # dass jedes Programm das selbst tut. %h = Home des jeweiligen Users.
  systemd.user.tmpfiles.rules = [
    "d %h/.cache        0700 - - -"
    "d %h/.config       0755 - - -"
    "d %h/.local        0755 - - -"
    "d %h/.local/share  0755 - - -"
    "d %h/.local/state  0755 - - -"
  ];

  
}