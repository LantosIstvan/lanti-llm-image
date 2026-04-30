#!/bin/sh
set -e

echo "Fixing permissions for mapped volumes..."
# A felcsatolt mappákat a Docker root-ként hozza létre, jogosultságot kell adni a comfyuser-nek
sudo chown -R comfyuser:comfyuser /usr/src/ComfyUI/user 2>/dev/null || true
sudo chown -R comfyuser:comfyuser /usr/src/ComfyUI/output 2>/dev/null || true
# sudo chown -R comfyuser:comfyuser /usr/src/ComfyUI/models/SEEDVR2 2>/dev/null || true

# Run command with python3 if the first argument contains a "-" or is not a system command. The last
# part inside the "{}" is a workaround for the following bug in ash/dash:
# https://bugs.debian.org/cgi-bin/bugreport.cgi?bug=874264
if [ "${1#-}" != "${1}" ] || [ -z "$(command -v "${1}")" ] || { [ -f "${1}" ] && ! [ -x "${1}" ]; }; then
  set -- python3 "$@"
fi

exec "$@"
