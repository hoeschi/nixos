{ config, pkgs, ... }:
{
  
  systemd.tmpfiles.rules = [
    "d /home/bhoesch/NAS 0755 bhoesch users -"
    "d /home/bhoesch/NAS/Bjarnes_Datenkerker 0755 bhoesch users -"
  ];

  fileSystems."/home/bhoesch/NAS/Bjarnes_Datenkerker" = {
    device = "//192.168.178.137/Bjarnes_Datenkerker";
    fsType = "cifs";
    options = [
      "credentials=/etc/samba/nas-credentials"
      "uid=${toString config.users.users.bhoesch.uid}"
      #"gid=${toString config.users.users.bhoesch.gid}"
      "file_mode=0644"   # Dateien: rw für Besitzer, r für andere
      "dir_mode=0755"    # Ordner: rwx für Besitzer, rx für andere
      "iocharset=utf8"
      "_netdev"
      "nofail"
      "x-systemd.automount"
      "x-systemd.idle-timeout=600s"
    ];
  };
}