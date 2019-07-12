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

PIPMODULES=(urllib3 pyopenssl certifi idna)
SETUPCFG="./setup.cfg"

# available functions

error_check() {
  # check whether any OS errors occurred after the last operation, if so -> exit
  if [[ $? != 0 ]]; then
    exit
  fi
}

command_exists () {
  # check whether the given command exists
  command -v "$1" > /dev/null 2>&1;
}

# check whether pip exists

if ! command_exists pip; then
  echo "downloading pip"
  if command_exists wget; then
    wget -c --no-check-certificate https://bootstrap.pypa.io/get-pip.py
    error_check
  elif command_exists curl; then
    curl https://bootstrap.pypa.io/get-pip.py
    error_check
  fi

  # install pip

  echo "installing pip; you may need your sudo password"
  sudo python get-pip.py
  error_check
fi

# current workaround for homebrew bug - DistutilsOptionError: must supply either home or prefix/exec-prefix — not both

/bin/cat <<EOF >${SETUPCFG}
[install]
prefix=
EOF

# install new modules

for thisModule in ${PIPMODULES[*]}; do
  pip install ${thisModule} --target ./ccpnmr2.4/python --upgrade
  error_check
done

# clean up to keep pip working

rm -rf ${SETUPCFG}
echo "finished."

