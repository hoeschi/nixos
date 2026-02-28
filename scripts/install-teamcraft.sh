#!/usr/bin/env bash
set -e

PREFIX="$HOME/.wine"
export WINEPREFIX="$PREFIX"

echo ">>> Verwende Wine-Prefix: $PREFIX"

if [ ! -d "$PREFIX" ]; then
    echo ">>> Erstelle neues Wine-Prefix..."
    wineboot --init
else
    echo ">>> Wine-Prefix existiert bereits."
fi

echo ">>> Installiere empfohlene Winetricks-Komponenten..."
winetricks -q corefonts

VERSION="11.4.19"
INSTALLER="ffxiv-teamcraft-Setup-$VERSION.exe"
URL="https://github.com/ffxiv-teamcraft/ffxiv-teamcraft/releases/download/v$VERSION/$INSTALLER"

DOWNLOAD_DIR="$HOME/Downloads/teamcraft"
mkdir -p "$DOWNLOAD_DIR"
cd "$DOWNLOAD_DIR"

echo ">>> Lade Teamcraft herunter..."
if [ ! -f "$INSTALLER" ]; then
    wget "$URL"
else
    echo ">>> Installer bereits vorhanden."
fi

echo ">>> Starte Installer..."
wine "$INSTALLER"

echo ">>> Suche nach installierter Teamcraft.exe..."

CANDIDATES=(
    "$PREFIX/drive_c/Program Files/Teamcraft/Teamcraft.exe"
    "$PREFIX/drive_c/Program Files (x86)/Teamcraft/Teamcraft.exe"
    "$PREFIX/drive_c/users/$USER/AppData/Local/Programs/teamcraft/Teamcraft.exe"
)

FOUND=""

for path in "${CANDIDATES[@]}"; do
    if [ -f "$path" ]; then
        FOUND="$path"
        break
    fi
done

if [ -z "$FOUND" ]; then
    echo "!!! Fehler: Teamcraft.exe wurde nicht gefunden."
    echo "!!! Möglicherweise hat der Installer einen anderen Pfad verwendet."
    echo ">>> Suche manuell mit:"
    echo "find \"$PREFIX\" -iname 'Teamcraft.exe'"
    exit 1
fi

echo ">>> Teamcraft wurde gefunden unter:"
echo "$FOUND"

WRAPPER="$HOME/.local/bin/teamcraft"

echo ">>> Erstelle Start-Skript unter $WRAPPER"

mkdir -p "$HOME/.local/bin"

cat > "$WRAPPER" <<EOF
#!/usr/bin/env bash
export WINEPREFIX="$PREFIX"
wine "$FOUND"
EOF

chmod +x "$WRAPPER"

echo
echo ">>> Installation abgeschlossen!"
echo ">>> Du kannst Teamcraft jetzt starten mit:"
echo "teamcraft"
