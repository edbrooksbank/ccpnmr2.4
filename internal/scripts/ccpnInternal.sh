#!/usr/bin/env bash

source ./paths.sh

# build paths
SKIP_SCRIPTS=""
SKIP_CODES=""
DATA_DIR=""
INCLUDE_FILES=""

# repositories contained in the project
REPOSITORY_NAMES=(ccpnmr2.4)
REPOSITORY_PATHS=(${CCPNMR_TOP_DIR})
REPOSITORY_RELATIVE_PATHS=("")
REPOSITORY_SOURCE=(https://github.com/VuisterLab)
