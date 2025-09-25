#!/usr/bin/env bash

set -euo pipefail

BASEDIR=$(dirname "$0")

[[ ! -f "${BASEDIR}/../.doppler" ]] && echo "[ERROR] - Doppler token file not found! Please create a .doppler file in the iac directory with your Doppler service token value as the contents...." && exit 1
[[ -z $(cat "${BASEDIR}/../.doppler") ]] && echo "[ERROR] - Doppler token file is empty! Please add your Doppler service token value as the contents of the .doppler file in the iac directory...." && exit 1

[[ $(command -v doppler || true) ]] || (echo "[ERROR] - Doppler CLI not found. Please install it from https://docs.doppler.com/docs/install-cli" && echo "You can also run 'make init' from the iac directory to install all prerequisites." && exit 1)
