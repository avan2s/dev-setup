#!/bin/bash
#
# Verbindet sich mit den SMB-Shares auf fileserver.conceto.local.
# Voraussetzung: VPN ist aktiv.
#
# Ausfuehren mit:   ./mount-fileserver.sh
#

SERVER="fileserver.conceto.local"
SHARES=("departments" "users")

# Pruefen, ob der Server ueber das VPN erreichbar ist
if ! ping -c 1 -t 3 "$SERVER" >/dev/null 2>&1; then
    echo "FEHLER: $SERVER ist nicht erreichbar. Bist du im VPN?"
    exit 1
fi

for share in "${SHARES[@]}"; do
    mountpoint="/Volumes/$share"

    # Schon gemountet? Dann ueberspringen.
    if mount | grep -q "on $mountpoint "; then
        echo "✓ $share ist bereits verbunden."
        continue
    fi

    echo "Verbinde mit smb://$SERVER/$share ..."
    # mount volume nutzt die Zugangsdaten aus dem Schluesselbund (wie der Finder).
    osascript -e "try
        mount volume \"smb://$SERVER/$share\"
    end try" >/dev/null 2>&1

    if mount | grep -q "on $mountpoint "; then
        echo "✓ $share verbunden."
    else
        echo "✗ $share konnte NICHT verbunden werden."
    fi
done
