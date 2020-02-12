#!/usr/bin/env bash
# build an AnalysisV3 release distribution
# ejb 11/9/17
#
# Remember to check out the required release in Pycharm, or manually with git in each repository.
#
# Take the existing RELEASE_VER version of Analysis from ./version.sh
# and create a HOME/release<Name>/RELEASE_VER directory as a stand-alone without
# development directories
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# import settings
source ./common.sh
source ./ccpnInternal.sh

BUILD_ZIP=true

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# start of code

# check whether using a Mac

check_darwin

# Check if all the git repositories are correct

echo "Checking git repositories:"
for thisrep in ${REPOSITORY_PATHS[*]}; do
  cd "${thisrep}" || exit
  check_git_repository
done

# Get the machine type to label the path

detect_os
if [[ ${MACHINE} == *"UNKNOWN"* ]]; then
  echo "machine not in [${OS_LIST[*]}]"
  continue_prompt "do you want to try an OS from the list?"
  show_choices
  read_choice ${#OS_LIST[@]} " select an OS from the list > "
fi

# setup correct folders for the Windows and others
if [[ "${MACHINE}" == *"Win"* ]]; then
  INCLUDE_DIRS="bat ccpnmr2.4 doc"
else
  INCLUDE_DIRS="bin ccpnmr2.4 doc"
fi

# set the new pathname

RELEASE_DEFAULT=""
read -rp "Enter name for release [${RELEASE_DEFAULT}]: " RELEASE_NAME
RELEASE_NAME="${RELEASE_NAME:-$RELEASE_DEFAULT}"

# remove all quotes and spaces - not needed here as an appended name
RELEASE_NAME="$(echo "${RELEASE_NAME}" | tr -d " \'\"\`")"

# make the required pathnames
RELEASE="release${RELEASE_NAME}"
CCPNMRPATH="ccpnmr${RELEASE_VER}"
CCPNMRFILE="ccpnmr${RELEASE_VER}${RELEASE_NAME}${MACHINE}"

## get the required LicenceKey file
#
#read -rp "Enter LicenceKey file: " LICENCEKEY_FILE
#
## remove all quotes - not needed here as a single filename - must keep spaces though
#LICENCEKEY_FILE="$(echo "${LICENCEKEY_FILE}" | tr -d "\'\"\`")"
#echo "${LICENCEKEY_FILE}"
#
#if [[ ! -f "${LICENCEKEY_FILE}" ]]; then
#  echo "Error reading LicenceKey file"
#  exit
#else
#  cp "${LICENCEKEY_FILE}" "${CCPNMR_TOP_DIR}/config/licenceKey.txt"
#  error_check
#fi
#
## get the required Licensing Document LICENSE.txt file
#
#read -rp "Enter Licence Document (LICENSE.txt): " LICENCE_DOCUMENT
#
## remove all quotes - not needed here as a single filename - must keep spaces though
#LICENCE_DOCUMENT="$(echo "${LICENCE_DOCUMENT}" | tr -d "\'\"\`")"
#echo "${LICENCE_DOCUMENT}"
#
#if [[ ! -f "${LICENCE_DOCUMENT}" ]]; then
#  echo "Error reading Licence Document"
#  exit
#else
#  cp "${LICENCE_DOCUMENT}" "${CCPNMR_TOP_DIR}/LICENSE.txt"
#  error_check
#fi

# Create new directory for the release

echo "creating new directory ${HOME}/${RELEASE}"
if [[ ! -d "${HOME}/${RELEASE}" ]]; then
  # create the new release directory
  mkdir -p "${HOME}/${RELEASE}"
  error_check
else
  continue_prompt "directory already exists, do you want to move it and continue?"
  DT=$(date '+%d-%m-%Y_%H:%M:%S')
  mv "${HOME}/${RELEASE}" "${HOME}/${RELEASE}_${DT}"
  error_check
fi

# Make current build in release directory

echo "Home:         ${HOME}"
echo "Release path: ${RELEASE}"
echo "CcpnNmrPath:  ${CCPNMRPATH}"
echo "File:         ${CCPNMRFILE}"

echo "creating new directory ${HOME}/${RELEASE}/${CCPNMRPATH}"
if [[ ! -d "${HOME}/${RELEASE}/${CCPNMRPATH}" ]]; then
  # create the new release directory
  mkdir -p "${HOME}/${RELEASE}/${CCPNMRPATH}"
  error_check
else
  continue_prompt "directory already exists, do you want to move it and continue?"
  DT=$(date '+%d-%m-%Y_%H:%M:%S')
  mv "${HOME}/${RELEASE}/${CCPNMRPATH}" "${HOME}/${RELEASE}/${CCPNMRPATH}_${DT}"
  error_check
fi

# Check if miniconda directory already exists

if [[ -d "${HOME}/${RELEASE}/${CCPNMRPATH}/miniconda" ]]; then
  continue_prompt "miniconda already exists, do you want to continue?"
  DT=$(date '+%d-%m-%Y_%H:%M:%S')
  mv "${HOME}/${RELEASE}/${CCPNMRPATH}/miniconda" "${HOME}/${RELEASE}/${CCPNMRPATH}/miniconda_${DT}"
  error_check
fi

# Tar up the directories (skipping internal)

echo "compressing main directory"
cd "${CCPNMR_TOP_DIR}" || exit
echo "${HOME}/${RELEASE}/repository${RELEASE_VER}.tgz"

if command_exists pigz; then
  echo "using pigz"
  tar --use-compress-program=pigz -cf "${HOME}/${RELEASE}/repository${RELEASE_VER}.tgz" ${INCLUDE_FILES} ${INCLUDE_DIRS} ${DATA_DIR}
else
  tar czf "${HOME}/${RELEASE}/repository${RELEASE_VER}.tgz" ${INCLUDE_FILES} ${INCLUDE_DIRS} ${DATA_DIR}
fi

# Unpack the tgz in ${HOME}/${RELEASE}/${CCPNMRPATH}

echo "unpacking main directory"
cd "${HOME}/${RELEASE}/${CCPNMRPATH}" || exit
tar xzf "../repository${RELEASE_VER}.tgz"
error_check

echo "removing repository${RELEASE_VER}.tgz"
rm -rf "../repository${RELEASE_VER}.tgz"
error_check

# Remove unneeded bin scripts:

echo "removing unneeded scripts"
if [[ -d "${HOME}/${RELEASE}/${CCPNMRPATH}/bin" ]]; then
  cd "${HOME}/${RELEASE}/${CCPNMRPATH}/bin" || exit
  rm -rf "${SKIP_SCRIPTS}"
fi

# Change version for update script (mistake, this should have been done in the repository)

# cd ${HOME}/${RELEASE}/${CCPNMRPATH}
# cd src/python/ccpn/util
# vi update.py [ etc.]

# Remove metabolomics and structure code

echo "removing unneeded code"
if [[ -d "${HOME}/${RELEASE}/${CCPNMRPATH}/src/python/ccpn" ]]; then
  cd "${HOME}/${RELEASE}/${CCPNMRPATH}/src/python/ccpn" || exit
  rm -rf "${SKIP_CODES}"
fi

# Copy miniconda code over:

echo "copying miniconda folder"
if [[ "${MACHINE}" == *"Win"* ]]; then
  cd "${HOME}/Anaconda3/envs" || exit
else
  cd "${HOME}/miniconda3/envs" || exit
fi

# need to be on the correct conda source

echo "compressing ${CONDA_SOURCE}"
if command_exists pigz; then
  echo "using pigz"
  tar --use-compress-program=pigz -cf "${CONDA_SOURCE}.tgz" "${CONDA_SOURCE}"
else
  tar czf "${CONDA_SOURCE}.tgz" "${CONDA_SOURCE}"
fi

error_check
mv "${CONDA_SOURCE}.tgz" "${HOME}/${RELEASE}/"

# move directory check for ${HOME}/${RELEASE}/${CCPNMRPATH}/miniconda to the top

echo "moving to ${RELEASE} directory"
cd "${HOME}/${RELEASE}/${CCPNMRPATH}" || exit
tar xzf "../${CONDA_SOURCE}.tgz"
error_check
rm -rf miniconda
mv -v "${CONDA_SOURCE}" miniconda

echo "removing ${CONDA_SOURCE}.tgz"
rm -rf "../${CONDA_SOURCE}.tgz"

# Fix miniconda library issues: - replaced
# convertPaths.py must have the correct __version__ in the headers
# cd ${HOME}/${RELEASE}/${CCPNMRPATH}
# this may be required to use miniconda as your default python environment
# python src/python/ccpn/util/convertPaths.py ${HOME}/${RELEASE}/${CCPNMRPATH}/miniconda ${HOME}/miniconda3/envs/$CONDA_SOURCE ${HOME}/${RELEASE}/${CCPNMRPATH}/miniconda

## compress the data directories into their own folder
#echo "extracting data directories"
#cd "${HOME}/${RELEASE}/${CCPNMRPATH}" || exit
#
## compress the data directory and remove from main folder
#
#if [[ "$DATA_DIR" != "" ]]; then
#  if command_exists pigz; then
#    echo "using pigz"
#    tar --use-compress-program=pigz -cf "${HOME}/${RELEASE}/data${RELEASE_VER}.tgz" ${DATA_DIR}
#  else
#    tar czf "${HOME}/${RELEASE}/data${RELEASE_VER}.tgz" ${DATA_DIR}
#  fi
#  if command_exists 7z && [[ "$BUILD_ZIP" == true ]]; then
#    echo "using 7z"
#    #zip -r -q ${HOME}/${RELEASE}/data${RELEASE_VER}.zip $DATA_DIR
#    #example for parallel 7zip: 7z a -t7z -mx=9 -m0=LZMA2 -mmt14 "Target.7z" "Source\*.*
#    7z a -tzip -bd "${HOME}/${RELEASE}/data${RELEASE_VER}.zip" ${DATA_DIR}
#  fi
#  rm -rf "${DATA_DIR}"
#fi

## extract the Licence file
#
#echo "extracting the licenceKey tgz/zip"
#tar czf "${HOME}/${RELEASE}/Licence.tgz" "./config/licenceKey.txt"
#zip -r -q "${HOME}/${RELEASE}/Licence.zip" "./config/licenceKey.txt"

# compress the remaining folder

echo "creating final tgz/zip"
cd "${HOME}/${RELEASE}" || exit
if command_exists pigz; then
  echo "using pigz"
#  tar --use-compress-program=pigz -cf "${HOME}/${RELEASE}/${CCPNMRFILE}.tgz" "${CCPNMRPATH}"
  tar cf - "${CCPNMRPATH}" | pigz > "${HOME}/${RELEASE}/${CCPNMRFILE}.tgz"
else
  tar czf "${HOME}/${RELEASE}/${CCPNMRFILE}.tgz" "${CCPNMRPATH}"
fi
if command_exists 7z && [[ "$BUILD_ZIP" == true ]]; then
  echo "using 7z"
  #zip -r -q ${HOME}/${RELEASE}/${CCPNMRFILE}.zip ${CCPNMRPATH}
  7z a -tzip -bd "${HOME}/${RELEASE}/${CCPNMRFILE}.zip" "${CCPNMRPATH}"
fi
echo "done"
