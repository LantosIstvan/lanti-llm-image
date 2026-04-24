#!/bin/sh
set -e

# These are only used in shell scripts, don't need to export
# DIR=$(realpath -s $PWD/$(dirname $0))
DIR=$( cd "$(dirname $0)" && pwd )

export ABS_PATH=$( cd "$DIR/.." && pwd )

# Needed for volumes
export UID=$(id -u)
export GID=$(id -g)

set -a && . $ABS_PATH/.env && set +a
