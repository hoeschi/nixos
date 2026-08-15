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
        flatpak.packages = [
          "com.bambulab.BambuStudio"
          "org.jdownloader.JDownloader"
        ];
      };
    };
  };
}