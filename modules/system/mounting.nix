{ config, pkgs, ... }:
{
  
  systemd.tmpfiles.rules = [
    "d /home/bhoesch/NAS 0755 bhoesch users -"
  ];

  fileSystems."/home/bhoesch/NAS" = {
    device = "//192.168.178.137/";
    fsType = "cifs";
    options = [
      "credentials=/etc/samba/nas-credentials"
      "uid=${toString config.users.users.bhoesch.uid}"
      "gid=${toString config.users.users.bhoesch.gid}"
      "iocharset=utf8"
      "_netdev"
      "nofail"
      "x-systemd.automount"
      "x-systemd.idle-timeout=60"
    ];
  };
}