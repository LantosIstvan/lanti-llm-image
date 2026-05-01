#!/bin/sh
set -e

echo "Fixing permissions for mapped volumes..."
# A felcsatolt mappákat a Docker root-ként hozza létre, jogosultságot kell adni a comfyuser-nek
sudo chown -R comfyuser:comfyuser /usr/src/ComfyUI/user 2>/dev/null || true
sudo chown -R comfyuser:comfyuser /usr/src/ComfyUI/output 2>/dev/null || true
# sudo chown -R comfyuser:comfyuser /usr/src/ComfyUI/models/SEEDVR2 2>/dev/null || true

echo "Configuring ComfyUI-Manager security settings..."
MANAGER_DIR="/usr/src/ComfyUI/user/__manager"
CONFIG_FILE="${MANAGER_DIR}/config.ini"

mkdir -p "$MANAGER_DIR"

# Ha még nem létezik a config fájl, létrehozzuk
if[ ! -f "$CONFIG_FILE" ]; then
cat <<EOF > "$CONFIG_FILE"
[default]
security_level = weak
network_mode = personal_cloud
EOF
else
    # Ha már létezik, felülírjuk a két kritikus értéket
    if grep -q "^\s*security_level" "$CONFIG_FILE"; then
        sed -i 's/^\s*security_level.*/security_level = weak/' "$CONFIG_FILE"
    else
        echo "security_level = weak" >> "$CONFIG_FILE"
    fi

    if grep -q "^\s*network_mode" "$CONFIG_FILE"; then
        sed -i 's/^\s*network_mode.*/network_mode = personal_cloud/' "$CONFIG_FILE"
    else
        echo "network_mode = personal_cloud" >> "$CONFIG_FILE"
    fi
fi

# Run command with python3 if the first argument contains a "-" or is not a system command. The last
# part inside the "{}" is a workaround for the following bug in ash/dash:
# https://bugs.debian.org/cgi-bin/bugreport.cgi?bug=874264
if [ "${1#-}" != "${1}" ] || [ -z "$(command -v "${1}")" ] || { [ -f "${1}" ] && ! [ -x "${1}" ]; }; then
  set -- python3 "$@"
fi

exec "$@"
