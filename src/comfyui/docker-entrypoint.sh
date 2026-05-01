#!/bin/sh
set -e

echo "Fixing permissions for mapped volumes..."
# A felcsatolt mappákat a Docker root-ként hozza létre, jogosultságot kell adni a comfyuser-nek
sudo chown -R comfyuser:comfyuser /usr/src/ComfyUI/user 2>/dev/null || true
sudo chown -R comfyuser:comfyuser /usr/src/ComfyUI/output 2>/dev/null || true

# TORCH.COMPILE CACHE JOGOSULTSÁG
mkdir -p /usr/src/ComfyUI/user/triton_cache
sudo chown -R comfyuser:comfyuser /usr/src/ComfyUI/user/triton_cache 2>/dev/null || true

echo "Configuring ComfyUI-Manager security settings..."
MANAGER_DIR="/usr/src/ComfyUI/user/__manager"
CONFIG_FILE="${MANAGER_DIR}/config.ini"

mkdir -p "$MANAGER_DIR"

# A szóköz az "if" és a "[" között kritikus a POSIX shellben
if [ ! -f "$CONFIG_FILE" ]; then
    cat <<EOF > "$CONFIG_FILE"
[default]
security_level = weak
network_mode = personal_cloud
EOF
else
    # Ha már létezik, felülírjuk a két kritikus értéket
    # A \s helyett [[:space:]] a POSIX szabványos megoldás whitespace-re
    if grep -q "^[[:space:]]*security_level" "$CONFIG_FILE"; then
        sed -i 's/^[[:space:]]*security_level.*/security_level = weak/' "$CONFIG_FILE"
    else
        echo "security_level = weak" >> "$CONFIG_FILE"
    fi

    if grep -q "^[[:space:]]*network_mode" "$CONFIG_FILE"; then
        sed -i 's/^[[:space:]]*network_mode.*/network_mode = personal_cloud/' "$CONFIG_FILE"
    else
        echo "network_mode = personal_cloud" >> "$CONFIG_FILE"
    fi
fi

echo "Applying patch for transformers>=5.5.0 flash_attn bug..."
PATCH_DIR="/usr/src/ComfyUI/custom_nodes/00_patch_transformers"
mkdir -p "$PATCH_DIR"
cat << 'EOF' > "$PATCH_DIR/__init__.py"
# Patch for transformers>=5.5.0 bug: 'flash_attn' missing from PACKAGE_DISTRIBUTION_MAPPING
try:
    from transformers.utils.import_utils import PACKAGE_DISTRIBUTION_MAPPING
    if "flash_attn" not in PACKAGE_DISTRIBUTION_MAPPING:
        PACKAGE_DISTRIBUTION_MAPPING["flash_attn"] =["flash_attn", "flash-attn"]
except Exception:
    pass

NODE_CLASS_MAPPINGS = {}
EOF
sudo chown -R comfyuser:comfyuser "$PATCH_DIR" 2>/dev/null || true

# Run command with python3 if the first argument contains a "-" or is not a system command. The last
# part inside the "{}" is a workaround for the following bug in ash/dash:
# https://bugs.debian.org/cgi-bin/bugreport.cgi?bug=874264
if [ "${1#-}" != "${1}" ] || [ -z "$(command -v "${1}")" ] || { [ -f "${1}" ] && ! [ -x "${1}" ]; }; then
  set -- python3 "$@"
fi

exec "$@"
