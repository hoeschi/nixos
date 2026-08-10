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

{ inputs, config, pkgs, ... }:

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

  services.open-webui = {
    enable = true;
    port = 8080;
    environment = {
      OLLAMA_BASE_URL = "http://127.0.0.1:11434";
      #WEBUI_SECRET_KEY = "…";  # für MCP nötig; besser via agenix/sops als Secret
      ENABLE_RAG_WEB_SEARCH = "true";
      ENABLE_WEB_SEARCH = "True";
      WEB_SEARCH_ENGINE = "searxng";
      SEARXNG_QUERY_URL = "http://127.0.0.1:8888/search?q=<query>";
      WEB_SEARCH_RESULT_COUNT = "5";
      WEB_SEARCH_CONCURRENT_REQUESTS = "0";
    };
  };

  services.searx = {
    enable = true;
    redisCreateLocally = true;              # richtet Valkey/Redis für den Limiter mit ein
    environmentFile = config.sops.secrets.searxng_env.path;

    settings = {
      server = {
        bind_address = "127.0.0.1";
        port = 8888;
        secret_key = "@SEARXNG_SECRET@";     # wird aus dem environmentFile ersetzt
      };
      search.formats = [ "html" "json" ];    # <-- DER kritische Punkt, sonst 403/leer
      ui.static_use_hash = true;
    };

    # SearXNG als HTTP-Endpunkt exponieren, den Open WebUI erreichen kann:
    configureUwsgi = true;
    uwsgiConfig = {
      http = "127.0.0.1:8888";
      disable-logging = true;
    };
  };

}
