#!/usr/bin/env bash

source ./paths.sh

# build paths
SKIP_SCRIPTS=""
SKIP_CODES=""
INCLUDE_DIRS="bin ccpnmr2.4 doc"
DATA_DIR="data"
INCLUDE_FILES=""

# repositories contained in the project
REPOSITORY_NAMES=(ccpnmr)
REPOSITORY_PATHS=(${CCPNMR_TOP_DIR})
REPOSITORY_RELATIVE_PATHS=("")
