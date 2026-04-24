#!/bin/sh
set -e

# https://ollama.readthedocs.io/en/modelfile/
# https://docs.openwebui.com/features/workspace/models/

MODELFILES_DIR=${OLLAMA_MODELFILES_DIR:-/modelfiles}

# Start ollama serve in the background.
ollama serve &
pid=$!

# Wait for the server to be fully ready.
while ! ollama list >/dev/null 2>&1; do
	echo "Waiting for Ollama server to be ready..."
	sleep 1
done

echo "Ollama server is ready."

# Check if the Modelfiles directory exists and contains files.
if [ -d "$MODELFILES_DIR" ] && [ -n "$(ls -A "$MODELFILES_DIR")" ]; then
	echo "Scanning for Modelfiles in '$MODELFILES_DIR'..."
	for modelfile in "$MODELFILES_DIR"/*.Modelfile; do
		# Derive the model name from the filename.
		CUSTOM_MODEL_NAME=$(basename "$modelfile" .Modelfile)
		echo "--- Processing model: $CUSTOM_MODEL_NAME ---"
		# If the model does not already exist, create it.
		if ! ollama list | awk '{print $1}' | grep -q "^${CUSTOM_MODEL_NAME}$"; then
			echo "Model '$CUSTOM_MODEL_NAME' not found. Creating it..."
			# This command handles everything. It will pull the base model
			# automatically if it is not present. This script does not parse the file.
			ollama create "$CUSTOM_MODEL_NAME" -f "$modelfile"
			echo "Successfully processed model '$CUSTOM_MODEL_NAME'."
		else
			echo "Model '$CUSTOM_MODEL_NAME' already exists. Skipping."
		fi
		echo "--- Finished processing: $CUSTOM_MODEL_NAME ---"
	done
else
	echo "No Modelfiles found. Skipping custom model creation."
fi

# Wait for the main ollama process.
wait $pid
