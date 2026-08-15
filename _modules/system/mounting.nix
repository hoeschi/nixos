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


  fileSystems."/home/bhoesch/NAS/Jellyfin" = {
    device = "192.168.178.137:/mnt/Storage_HDD/Jellyfin";
    fsType = "nfs";
    options = [
      "nfsvers=4"
      "hard"
      "intr"
      "rsize=1048576"
      "wsize=1048576"
      "async"
      "x-systemd.automount"
      "noauto"
      "x-systemd.idle-timeout=600"
    ];
  };
}