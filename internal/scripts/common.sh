#!/usr/bin/env bash

# import settings
source ./version.sh
source ./paths.sh

# Operating system list
OS_LIST=(Linux MacOS Windows Irix Solaris)
PYQT="PyQt5"

# available functions

check_git_repository() {
  # check that the current path contains the correct branch
  GIT_BRANCH="$(git rev-parse --abbrev-ref HEAD)"
  THIS_PATH="$(pwd)"

  if [[ ${GIT_BRANCH} == "${GIT_RELEASE}" ]]; then
    echo "correct git branch on path: $THIS_PATH"
  else
    echo "*** Not correct branch ***"
    exit
  fi
}

continue_prompt() {
  # prompt for a yes/no answer
  # much safer to wait for the user to press return
  # answering no will terminate
  while true; do
    read -rp "$1 [Yy/Nn]" yn
      case ${yn} in
          [Yy]* ) break;;
          [Nn]* ) exit;;
          * ) echo "Please answer [Yy/Nn]";;
      esac
  done
}

yesno_prompt() {
  # prompt for a yes/no answer
  # much safer to wait for the user to press return
  while true; do
    read -rp "$1 [Yy/Nn]" yn
      case ${yn} in
          [Yy]* ) ANS="yes"; break;;
          [Nn]* ) ANS="no"; break;;
          * ) echo "Please answer [Yy/Nn]";;
      esac
  done
}

detect_os() {
  # detect the current OS type
  unameOut="$(uname -s)"
  case "${unameOut}" in
      Linux*)     MACHINE=Linux;;
      Darwin*)    MACHINE=MacOS;;
      CYGWIN*)    MACHINE=Windows;;
      IRIX*)      MACHINE=Irix;;
      Sun*)       MACHINE=Solaris;;
      *)          MACHINE="UNKNOWN:${unameOut}"
  esac
}

show_choices() {
  # show OS choices in a table
  echo "OS types allowed"
  echo "~~~~~~~~~~~~~~~~"
  INDEX=1
  for thisOS in ${OS_LIST[*]}; do
    echo "  $INDEX. $thisOS"
    INDEX=$((INDEX+1))
  done
  echo "  $INDEX. exit"
  EXIT_VAL=${INDEX}
}

get_digit() {
  # read a digit from the user, until between 1 and n
  while true; do
    read -rsn1 NUM
      case ${NUM} in
          [0123456789]* ) echo "${NUM}"; break;;
          * ) ;;
      esac
  done
}

read_choice() {
  # read a choice from the user
  CHOICE=0
  while true; do
    read -rp "$2" CHOICE
    if [[ $((CHOICE)) != "${CHOICE}" ]]; then
      echo "not a number"
    else
      if [[ ${CHOICE} == $(($1+1)) ]]; then
        exit
      fi
      if [[ ${CHOICE} -ge 1 && ${CHOICE} -le $1 ]]; then
        break
      fi
    fi
  done
  MACHINE=${OS_LIST[$((CHOICE-1))]}
}

execute_codeblock() {
  # prompt for a yes/no answer
  while true; do
    read -rp "$1 [Yy/Nn]" yn
      case ${yn} in
          [Yy]* ) echo 'True'; break;;
          [Nn]* ) echo 'False'; break;;
          * ) echo "Please answer [Yy/Nn]";;
      esac
  done
}

space_continue() {
  # wait for space bar
  read -n1 -rp "press space to continue..." KEY
  echo ""
}

error_check() {
  # check whether any OS errors occured after the last operation
  if [[ $? != 0 ]]; then
    exit
  fi
}

function relative_path() {
  # return the relative path to the current path
  python -c "import os,sys;print (os.path.relpath(*(sys.argv[1:])))" "$@";
}

command_exists () {
  # check whether the given command exists
  command -v "$1" > /dev/null 2>&1;
}

check_darwin() {
  # check if using a Mac
  if [[ "$(uname -s)" == 'Darwin*' ]]; then
    export DYLD_FALLBACK_LIBRARY_PATH=/System/Library/Frameworks/ApplicationServices.framework/Versions/A/Frameworks/ImageIO.framework/Versions/A/Resources:
    export DYLD_FALLBACK_LIBRARY_PATH=${DYLD_FALLBACK_LIBRARY_PATH}${ANACONDA3}/lib:
    export DYLD_FALLBACK_LIBRARY_PATH=${DYLD_FALLBACK_LIBRARY_PATH}${ANACONDA3}/lib/python3.5/site-packages/${PYQT}:
    export DYLD_FALLBACK_LIBRARY_PATH=${DYLD_FALLBACK_LIBRARY_PATH}${HOME}/lib:/usr/local/lib:/usr/lib
  fi
}

die_getopts () {
    echo "ERROR: $*." >&2
    exit 1
}

isDirInPath() {
  # check whether the PATH contains a given directory
  case ":${PATH}:" in
    *:"$1":*) return 0 ;;
    *) return 1 ;;
  esac
}
