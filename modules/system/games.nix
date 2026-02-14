{ config, pkgs, ... }:
{
    environment.systemPackages = with pkgs; [

        xivlauncher

    ];
}
