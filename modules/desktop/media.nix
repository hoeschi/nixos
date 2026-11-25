{den, ...}: {
  den.aspects.media = {
    nixos = {pkgs, ...}: {
      environment.systemPackages = with pkgs; [
        vlc

        # Blu-ray-Wiedergabe (Kopierschutz/Menüs)
        libbluray
        libaacs
        libbdplus

        # Download & Bearbeitung
        yt-dlp
        ffmpeg
        mkvtoolnix
        bento4 # mp4decrypt für Crunchyroll-Downloads
        #makemkv
      ];
    };
  };
}
