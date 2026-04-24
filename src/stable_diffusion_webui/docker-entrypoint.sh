#!/bin/sh
set -e

# Run command with python3 if the first argument contains a "-" or is not a system command. The last
# part inside the "{}" is a workaround for the following bug in ash/dash:
# https://bugs.debian.org/cgi-bin/bugreport.cgi?bug=874264
if [ "${1#-}" != "${1}" ] || [ -z "$(command -v "${1}")" ] || { [ -f "${1}" ] && ! [ -x "${1}" ]; }; then
  set -- python3 "$@"
fi

exec "$@"




# #!/bin/sh
# set -e

# # --- Read the Hugging Face Token from the Environment Variable ---
# if [ -z "$HUGGING_FACE_HUB_TOKEN" ]; then
#   echo "❌ ERROR: HUGGING_FACE_HUB_TOKEN environment variable is not set."
#   echo "Please export this variable on your host machine before running 'docker compose up'."
#   exit 1
# fi

# # --- Define standard A1111 directories inside the container ---
# CHECKPOINT_DIR="${APP_DIR}/models/Stable-diffusion"
# VAE_DIR="${APP_DIR}/models/VAE"
# CLIP_DIR="${APP_DIR}/models/clip" # Directory for SD3/3.5 text encoders

# # --- Create directories if they don't exist ---
# # These directories will be created inside the mounted volumes.
# mkdir -p "$CHECKPOINT_DIR" "$VAE_DIR" "$CLIP_DIR"

# # --- Helper function to download a single file with authentication ---
# # Usage: download_file "REPO_ID" "FILE_PATH_IN_REPO" "TARGET_DIRECTORY"
# download_file() {
#   REPO_ID="$1"
#   FILE_PATH="$2"
#   TARGET_DIR="$3"
#   FILENAME=$(basename "$FILE_PATH")
#   TARGET_FILE="${TARGET_DIR}/${FILENAME}"

#   if [ -f "$TARGET_FILE" ]; then
#     echo "✅ $FILENAME already exists, skipping download."
#   else
#     echo "🔽 Downloading $FILENAME..."
#     # Construct the download URL and use wget with the auth token
#     URL="https://huggingface.co/${REPO_ID}/resolve/main/${FILE_PATH}"
#     wget --header="Authorization: Bearer ${HUGGING_FACE_HUB_TOKEN}" "$URL" -O "$TARGET_FILE"
#     echo "✅ Finished downloading $FILENAME."
#   fi
# }

# # --- Download Stable Diffusion 3.5 Medium model ---
# download_file "stabilityai/stable-diffusion-3.5-medium" "sd3.5_medium.safetensors" "$CHECKPOINT_DIR"

# # --- Download REQUIRED Text Encoders for SD 3.5 ---
# # The model will not work without these. They must be in the 'models/clip' directory.
# download_file "stabilityai/stable-diffusion-3.5-medium" "text_encoders/clip_g.safetensors" "$CLIP_DIR"
# download_file "stabilityai/stable-diffusion-3.5-medium" "text_encoders/clip_l.safetensors" "$CLIP_DIR"
# download_file "stabilityai/stable-diffusion-3.5-medium" "text_encoders/t5xxl_fp8_e4m3fn.safetensors" "$CLIP_DIR"

# # --- Download Recommended VAE (improves colors and details) ---
# # This repository is not gated, so token is not strictly needed but the function works fine.
# download_file "stabilityai/sdxl-vae" "sdxl_vae.safetensors" "$VAE_DIR"

# echo "--- Model checks complete. Starting the Web UI... ---"

# # --- Original entrypoint logic ---
# if [ "${1#-}" != "${1}" ] || [ -z "$(command -v "${1}")" ] || { [ -f "${1}" ] && ! [ -x "${1}" ]; }; then
#   set -- python3 "$@"
# fi

# exec "$@"
