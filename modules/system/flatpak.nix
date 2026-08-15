{
  den,
  inputs,
  ...
}:
{
  den.aspects.system.provides.flatpak = {

    nixos = {pkgs, ...}:
    {
      imports = [ inputs.nix-flatpak.nixosModules.nix-flatpak ];
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