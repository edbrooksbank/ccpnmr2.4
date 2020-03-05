#!/usr/bin/env bash
# Compile C Code for te current environment, should be executed from the end of installMiniconda
# ejb 19/9/17
#
# Remember to check out the required release in Pycharm, or manually with git in each repository.
#
# recompile the c code in the src/c directory
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# import settings
source ./common.sh

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# start of code

detect_os
if [[ "$MACHINE" == *"UNKNOWN"* ]]; then
    echo "machine not in [${OS_LIST[*]}]"
    continue_prompt "do you want to try an OS from the list?"
    show_choices
    read_choice ${#OS_LIST[@]} " select an OS from the list > "
fi
if [[ ${MACHINE} == *"MacOS"* ]]; then
    # required for getting the correct path from miniconda website
    MACOSAPPEND='X'
fi

BIT_COUNT="$(uname -m)"
echo "current machine: ${MACHINE}, ${BIT_COUNT}"

# check whether using a Mac

check_darwin

# make a symbolic link for the miniconda path (if it does not exists)

if [[ ${MACHINE} == *"Windows"* ]]; then
    # easier with Anaconda
    CONDA_PATH="${HOME}/Anaconda3"
else
    CONDA_PATH="${HOME}/miniconda3"
fi
CONDA_CCPN_PATH="${CONDA_PATH}/envs/${CONDA_SOURCE}"
cd "${CCPNMR_TOP_DIR}" || exit
if [[ ! -d "${CONDA_CCPN_PATH}" ]]; then
    echo "Error compiling - conda environment ${CONDA_SOURCE} does not exist"
    exit
fi
if [[ ! -d miniconda ]]; then
    if [[ ${MACHINE} == *"Windows"* ]]; then
        # easier o make a link with a windows shell
        echo "Please open Windows shell and copy below to make link (easiest way) and rerun script:"
        echo "   cd ${CCPNMR_TOP_DIR}"
        echo "   mklink /D miniconda ${CONDA_CCPN_PATH}"
        exit
    else
        echo "Creating miniconda symbolic link"
        ln -s "${CONDA_CCPN_PATH}" miniconda
    fi
fi

# copy the correct environment file

echo "compiling C Code"
cd "${CCPNMR_TOP_DIR}/${VERSIONPATH}/c" || exit

echo "using environment_${MACHINE}.txt"
if [[ ! -f environment_${MACHINE}.txt ]]; then
    echo "environment doesn't exists with this name, please copy closest and re-run compileCCode"
    exit
fi

# run 'make'

echo "setting up environment file"

# copy the required environment for the makefile
CONDA_HEADER="PYTHON_DIR = ${ANACONDA3}"
CONDA_HEADER_ENV="CONDA_ENV = ${CONDA_SOURCE}"

cp "environment_${MACHINE}.txt" environment.txt
error_check

# insert the PYTHON_DIR and CONDA_ENV into the first line of the environment file (CONDA_ENV not strictly required)
sed -i.bak "1 s|^.*$|${CONDA_HEADER}|" environment.txt && rm -rf environment.txt.bak
sed -i.bak "2 s|^.*$|${CONDA_HEADER_ENV}|" environment.txt && rm -rf environment.txt.bak

echo "making path ${CCPNMR_TOP_DIR}/${VERSIONPATH}/c"
if [[ ${MACHINE} != *"Windows"* ]]; then
    make -B $*
else
    echo "Please use 'nmake' from an x64 terminal in the above path to compile."
fi
