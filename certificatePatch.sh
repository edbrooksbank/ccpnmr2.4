#!/usr/bin/env bash
#
# Install the new python modules needed to fix the certificate errors with the new server
# All further updates should then be available from the server
#
# execute this script with:
#    ./certificatePatch.sh
#
# If there is an error, you may have to run as superuser
#    sudo ./certificatePatch.py
#
# Please ignore the deprecation warnings, python2.7 is soon to expire

# modules to import

PIPMODULES="urllib3 pyopenssl certifi idna"
SETUPCFG="./setup.cfg"

# available functions

error_check() {
  # check whether any OS errors occurred after the last operation, if so -> exit
  if [[ $? != 0 ]]; then
    rm -rf ${SETUPCFG}
    exit
  fi
}

command_exists() {
  # check whether the given command exists
  command -v "$1" > /dev/null 2>&1;
}

detect_os() {
  # detect the current OS type
  unameOut="$(uname -s)"
  case "${unameOut}" in
      Linux*)     MACHINE=Linux;;
      Darwin*)    MACHINE=MacOSX;;
      CYGWIN*)    MACHINE=Windows;;
      IRIX*)      MACHINE=Irix;;
      Sun*)       MACHINE=Solaris;;
      *)          MACHINE="UNKNOWN:${unameOut}"
  esac
}

isDirInPath() {
  # check whether the PATH contains a given directory
  case ":$PATH:" in
    *:"$1":*) return 0 ;;
    *) return 1 ;;
  esac
}

# check whether pip exists

if ! command_exists pip; then
  echo "downloading pip"
  if command_exists wget; then
    wget -c --no-check-certificate https://bootstrap.pypa.io/get-pip.py
    error_check
  elif command_exists curl; then
    curl -O -L https://bootstrap.pypa.io/get-pip.py
    error_check
  fi

  # install pip

  echo "installing pip; you may need your sudo password"
  sudo python get-pip.py
  error_check
fi

# current workaround for homebrew bug - DistutilsOptionError: must supply either home or prefix/exec-prefix — not both

echo "[install]" > ${SETUPCFG}
echo "prefix=" >> ${SETUPCFG}

# check whether PATH contains /Library/... (on MacOSX)

detect_os
if [[ ${MACHINE} == *"MacOSX"* ]]; then
  if ! isDirInPath "/Library/Frameworks/Python.framework/Versions/2.7/bin"; then
    PATH=${PATH}:/Library/Frameworks/Python.framework/Versions/2.7/bin
  fi
fi

# install new modules

pip install --target ./ccpnmr2.4/python --upgrade ${PIPMODULES}
error_check

# clean up to keep pip working

rm -rf ${SETUPCFG}
error_check
echo "finished."

