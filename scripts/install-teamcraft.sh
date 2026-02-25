#!/usr/bin/env bash
set -e

# Standard-Wine-Prefix
PREFIX="$HOME/.wine"
export WINEPREFIX="$PREFIX"

echo ">>> Verwende Wine-Prefix: $PREFIX"

# Prefix initialisieren, falls nicht vorhanden
if [ ! -d "$PREFIX" ]; then
    echo ">>> Erstelle neues Wine-Prefix..."
    wineboot --init
else
    echo ">>> Wine-Prefix existiert bereits, überspringe Initialisierung."
fi

echo ">>> Installiere empfohlene Winetricks-Komponenten..."
winetricks -q corefonts

# Teamcraft Version
VERSION="11.4.19"
INSTALLER="Teamcraft-Setup-$VERSION.exe"
URL="https://github.com/ffxiv-teamcraft/ffxiv-teamcraft/releases/download/v$VERSION/$INSTALLER"

# Download-Verzeichnis
DOWNLOAD_DIR="$HOME/Downloads/teamcraft"
mkdir -p "$DOWNLOAD_DIR"
cd "$DOWNLOAD_DIR"

echo ">>> Lade Teamcraft $VERSION herunter..."
if [ ! -f "$INSTALLER" ]; then
    wget "$URL"
else
    echo ">>> Installer bereits vorhanden, überspringe Download."
fi

echo ">>> Starte Teamcraft-Installer..."
wine "$INSTALLER"

APP_PATH="$PREFIX/drive_c/Program Files/Teamcraft/Teamcraft.exe"

echo
if [ -f "$APP_PATH" ]; then
    echo ">>> Teamcraft wurde erfolgreich installiert!"
    echo ">>> Starte Teamcraft mit:"
    echo "WINEPREFIX=$PREFIX wine \"$APP_PATH\""
else
    echo "!!! Fehler: Teamcraft.exe wurde nicht gefunden."
    echo "!!! Prüfe, ob der Installer korrekt durchgelaufen ist."
fi
