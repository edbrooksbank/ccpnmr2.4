#!/usr/bin/env bash

CCPNMR_TOP_DIR="$(cd "$(dirname "$0")/.." || exit; pwd)"
export CCPNMR_TOP_DIR
export VERSIONPATH=ccpnmr2.5
export ANACONDA3="${CCPNMR_TOP_DIR}"/miniconda
export PYTHONPATH="${CCPNMR_TOP_DIR}/${VERSIONPATH}/python"
export FONTCONFIG_FILE="${ANACONDA3}"/etc/fonts/fonts.conf
export FONTCONFIG_PATH="${ANACONDA3}"/etc/fonts

UNAME="$(uname -s)"
if [[ ${UNAME} == 'Darwin' ]]; then
  export DYLD_FALLBACK_LIBRARY_PATH=/System/Library/Frameworks/ApplicationServices.framework/Versions/A/Frameworks/ImageIO.framework/Versions/A/Resources:
  export DYLD_FALLBACK_LIBRARY_PATH=${DYLD_FALLBACK_LIBRARY_PATH}"${ANACONDA3}"/lib:
  export DYLD_FALLBACK_LIBRARY_PATH=${DYLD_FALLBACK_LIBRARY_PATH}${HOME}/lib:/usr/local/lib:/usr/lib:
fi
