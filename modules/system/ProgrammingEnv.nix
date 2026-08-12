{config, pkgs, lib, ...}:
{
  
  users.users.bhoesch.extraGroups = [ "dialout" ];

  services.udev.extraRules = ''
    # Espressif native USB (ESP32-C3/C6/S2/S3 USB-Serial-JTAG)
    SUBSYSTEM=="usb", ATTR{idVendor}=="303a", MODE="0666", GROUP="dialout"
    SUBSYSTEM=="tty", ATTRS{idVendor}=="303a", MODE="0660", GROUP="dialout"
  '';

}