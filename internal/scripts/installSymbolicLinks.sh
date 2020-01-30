#!/usr/bin/env bash
# install for development environment
# ejb 19/9/17; update 9/10/19 - moved out of ./installDevelopment due to possible bad paths
#
# Set up all git symbolic links
# to process headers during pre-commit
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# import settings
source ./common.sh
source ./ccpnInternal.sh

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# start of code

# links for the commit scripts
SYMBOLIC_COMMIT_LINKS=(pre-commit post-commit)
SYMBOLIC_COMMIT_PATH="/internal/src/python/git_hooks/"

# links for the script to process file headers
SYMBOLIC_LINKS=(CheckHeader.py)
SYMBOLIC_LINKS_PATH="/internal/src/python/"
HOOKS_PATH=".git/hooks/"

# check whether using a Mac

check_darwin

# remove any existing symbolic links and add new

if [[ -d ${CCPNMR_TOP_DIR} ]]; then

  # cleaning existing links

  echo "cleaning existing symbolic links"
  cd "${CCPNMR_TOP_DIR}" || exit
  error_check
  find . -name "pre-commit" -type l -delete
  find . -name "post-commit" -type l -delete
  find . -name "CheckHeader.py" -type l -delete

  # add new symbolic links
  # link is from ./internal/src/python/git_hooks/ to .git/hooks each of the repositories

  echo "creating symbolic links"
  for THIS_REP in ${REPOSITORY_PATHS[*]}; do
    if [[ -d ${THIS_REP} ]]; then
      cd "${THIS_REP}" || exit

      echo "Repository: ${THIS_REP}"
      RELATIVE_PATH=$(relative_path "${CCPNMR_TOP_DIR}${SYMBOLIC_COMMIT_PATH}" "${HOOKS_PATH}")
      for THIS_FILE in ${SYMBOLIC_COMMIT_LINKS[*]}; do
        CLIPPED_FILE=$(echo "${RELATIVE_PATH}/${THIS_FILE}" | cut -d'/' -f3- )

        if [[ -f ${CLIPPED_FILE} && -d "${HOOKS_PATH}" ]]; then
          echo "linking ${THIS_FILE}: ${RELATIVE_PATH} -> ${HOOKS_PATH}"
          ln -s "${RELATIVE_PATH}/${THIS_FILE}" "${HOOKS_PATH}${THIS_FILE}"
        fi
      done

      RELATIVE_PATH=$(relative_path "${CCPNMR_TOP_DIR}${SYMBOLIC_LINKS_PATH}" "${HOOKS_PATH}")
      for THIS_FILE in ${SYMBOLIC_LINKS[*]}; do
        CLIPPED_FILE=$(echo "${RELATIVE_PATH}/${THIS_FILE}" | cut -d'/' -f3- )

        if [[ -f ${CLIPPED_FILE} && -d "${HOOKS_PATH}" ]]; then
          echo "linking ${THIS_FILE}: ${RELATIVE_PATH} -> ${HOOKS_PATH}"
          ln -s "${RELATIVE_PATH}/${THIS_FILE}" "${HOOKS_PATH}${THIS_FILE}"
        fi
      done
    fi
  done
fi
