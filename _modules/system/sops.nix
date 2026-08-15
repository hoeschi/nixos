{ inputs, config, pkgs, ... }:
{
    sops = {

      defaultSopsFile = ../../secrets/secrets.yaml;   # Pfad relativ zu deinem Modul anpassen
      age.keyFile = "/home/bhoesch/.config/sops/age/keys.txt";
      secrets.searxng_env = {
        owner = "searx";   # der searx-Dienst muss die entschlüsselte Datei lesen können
      };

    };

}