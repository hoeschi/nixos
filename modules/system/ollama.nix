# ollama.nix
# Importieren in configuration.nix:
#   imports = [ ./ollama.nix ];
#
# Nach Änderungen aktivieren:
#   sudo nixos-rebuild switch
#
# Modell laden (einmalig):
#   ollama pull llama3.2
#
# GPU-Nutzung prüfen:
#   ollama ps

{ pkgs, ... }:

{
  # Ollama mit AMD ROCm GPU-Beschleunigung
  services.ollama = {
    enable = true;
    package = pkgs.ollama-rocm;

    # RX 9070 XT = RDNA 4 = gfx1201
    # Falls die GPU nicht erkannt wird: `rocminfo | grep gfx` ausführen
    # und den zurückgegebenen Wert hier eintragen (z.B. "11.0.0" für RDNA 3)
    #rocmOverrideGfx = "12.0.1";

    # Auf allen Interfaces lauschen, damit Odysseus den Endpoint erreichen kann.
    # Nur auf localhost ändern ("127.0.0.1") wenn kein externer Zugriff gewünscht ist.
    host = "0.0.0.0";
    port = 11434;
  };

  # Benutzer muss in diesen Gruppen sein damit Docker bzw. ROCm auf die GPU zugreifen kann.
  users.users.bhoesch = {
    extraGroups = [ "video" "render" ];
  };

  networking.firewall.allowedTCPPorts = [ 11434 ];
}
