{
  den,
  ...
}:
{
  den.aspects.system.provides.flatpak = {

    nixos = {pkgs, ...}:
    {
      services = {
        flatpak.enable = true;
        flatpak.package = [
          "com.bambulab.BambuStudio"
          "org.jdownloader.JDownloader"
        ];
      };
    };
  };
}