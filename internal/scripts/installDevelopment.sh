#!/usr/bin/env bash
# install for development environment
# ejb 19/9/17
#
# download all repositories, set up all git symbolic links and environment.
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# import settings
source ./common.sh
source ./ccpnInternal.sh

ANALYSIS_DEFAULT=${HOME}/Projects/ccpnmr2.5

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# start of code

echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
echo "CcpNmr AnalysisV3 installation"
echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"

# process arguments

# -i : ignore those repositories that have already been downloaded
# -c : clone repository
# -g : checkout the release repository
# -p : specify path for project
# -k : generate ssh-keygen for git

while getopts ":iIcClLgGp:PkKh" OPT; do
    case ${OPT} in
        #i)   IGNORE=${OPTARG};;  if using i: then expects an arg
        i)
            [[ "${IGNORE_ARG}" != "" ]] && die_getopts "-iI already specified"
            IGNORE_ARG=False
            ;;
        c)
            [[ "${CLONE_ARG}" != "" ]] && die_getopts "-cC already specified"
            CLONE_ARG=False
            ;;
        g)
            [[ "${GIT_CHECKOUT_ARG}" != "" ]] && die_getopts "-gG already specified"
            GIT_CHECKOUT_ARG=False
            ;;
        p)
            [[ "${PATH_ARG}" != "" ]] && die_getopts "-pP already specified"
            PATH_ARG=${OPTARG}
            ;;
        k)
            [[ "${KEYGEN_ARG}" != "" ]] && die_getopts "-kK already specified"
            KEYGEN_ARG=False
            ;;
        I)
            [[ "${IGNORE_ARG}" != "" ]] && die_getopts "-iI already specified"
            IGNORE_ARG=True
            ;;
        C)
            [[ "${CLONE_ARG}" != "" ]] && die_getopts "-cC already specified"
            CLONE_ARG=True
            ;;
        G)
            [[ "${GIT_CHECKOUT_ARG}" != "" ]] && die_getopts "-gG already specified"
            GIT_CHECKOUT_ARG=True
            ;;
        P)
            [[ "${PATH_ARG}" != "" ]] && die_getopts "-pP already specified"
            PATH_ARG=${ANALYSIS_DEFAULT}
            ;;
        K)
            [[ "${KEYGEN_ARG}" != "" ]] && die_getopts "-kK already specified"
            KEYGEN_ARG=True
            ;;
        h)
            echo "Usage: $0"
            echo "-cC clone repositories"
            echo "-iI ignore repositories that have been downloaded"
            echo "-gG checkout the release branch defined in version.sh"
            echo "-p <path> specify path for analysisV3"
            echo "-kK generate ssh-keygen for git/bitbucket"
            echo "-h display help"
            echo "-P use default path <${ANALYSIS_PATH}>"
            echo "use uppercase to set True, lowercase to set to False. Unset will request input."
            exit
            ;;
        *)
            echo $"Usage: $0 -icgpkh"
            exit
            ;;
    esac
done
shift $((OPTIND - 1))

# initialise parent path

if [[ "${PATH_ARG}" == "" ]]; then
    read -rp "Please enter path for AnalysisV3 [${ANALYSIS_DEFAULT}]: " ANALYSIS_PATH
else
    ANALYSIS_PATH=${PATH_ARG}
fi
ANALYSIS_PATH="${ANALYSIS_PATH:-$ANALYSIS_DEFAULT}"

if [[ ! -d ${ANALYSIS_PATH} ]]; then
    continue_prompt "create new directory ${ANALYSIS_PATH} and continue?"
    echo "creating directory"
    mkdir -p "${ANALYSIS_PATH}"
else
    continue_prompt "directory ${ANALYSIS_PATH} exists, do you want to continue?"
fi

# check whether using a Mac

check_darwin

# ask for inputs at the beginning of script

if [[ "${CLONE_ARG}" != "True" ]]; then
    CLONE=$(execute_codeblock "do you want to clone repositories?")
fi
if [[ "${IGNORE_ARG}" != "True" ]]; then
    IGNORE=$(execute_codeblock "do you want to ignore existing repositories?")
fi
if [[ "${GIT_CHECKOUT_ARG}" != "True" ]]; then
    GIT_CHECKOUT=$(execute_codeblock "do you want to checkout ${GIT_RELEASE}?")
fi
if [[ "${KEYGEN_ARG}" != "True" ]]; then
    KEYGEN=$(execute_codeblock "do you want to create an SSH key?")
fi

# create an SSH key for git access

if [[ "${KEYGEN}" == "True" ]]; then
    echo "generating ssh-key"
    ssh-keygen

    echo "...A website should have opened to https://bitbucket.org"
    echo "login; navigate to 'Your profile and settings'"
    echo "                     'Bitbucket settings'"
    echo "                       'Security: SSH Keys'"
    echo "and click 'Add Key'"
    echo "paste the whole of the following line into the box labelled 'Key*':"
    cat "${HOME}/.ssh/id_rsa.pub"

    python -m webbrowser -t "https://bitbucket.org"
    space_continue

    if [[ $(execute_codeblock "do you want to test your ssh-key?") == 'True' ]]; then
        echo "test ssh"
        CHECK_GIT=$(ssh -T git@bitbucket.org)
        if [[ "${CHECK_GIT}" == *"logged in as"* ]]; then
            echo "ssh-key okay"
        else
            echo "ssh-key not working"
            exit
        fi
    fi
fi

# need to download/clone and set up repositories here

if [[ "${CLONE}" == "True" ]]; then
    echo "clone repositories"

    for ((REP = 0; REP < ${#REPOSITORY_NAMES[@]}; REP++)); do

        # concatenate paths to give the correct install path
        # paths are defined in ./ccpnInternal.sh
        THIS_REP=${REPOSITORY_NAMES[$REP]}
        THIS_PATH=${ANALYSIS_PATH}${REPOSITORY_RELATIVE_PATHS[$REP]}
        THIS_SOURCE=${REPOSITORY_SOURCE[$REP]}

        echo "Cloning repository into ${THIS_PATH}"

        #PARENT=$(echo ${THIS_PATH} | rev | cut -d'/' -f2- | rev)
        if [[ -d ${THIS_PATH} ]]; then
            # cloning into an already existing path will cause fatal git error
            # if the path already exists, it will be moved to path with date/time extension
            # as it starts with the top-level, the first move will move everything

            if [[ "${IGNORE}" == "False" ]]; then # ignore if flag and already exists
                DT=$(date '+%d-%m-%Y_%H:%M:%S')
                OLD_PATH=${THIS_PATH}_${DT}
                continue_prompt "directory already exists, do you want to continue?"
                continue_prompt "ARE YOU SURE, IT WILL BE MOVED TO: ${OLD_PATH} ?"

                # move old and clone the repository

                mv "${THIS_PATH}" "${OLD_PATH}"
                error_check
                #        git clone git@bitbucket.org:ccpnmr/"${THIS_REP}".git "${THIS_PATH}"
                git clone "${THIS_SOURCE}/${THIS_REP}".git "${THIS_PATH}"
            fi
        else
            #      git clone git@bitbucket.org:ccpnmr/"${THIS_REP}".git "${THIS_PATH}"
            git clone "${THIS_SOURCE}/${THIS_REP}".git "${THIS_PATH}"
        fi
    done
fi

# checkout the required release

if [[ "${GIT_CHECKOUT}" == "True" ]]; then
    echo "switching repositories to branch ${GIT_RELEASE}"

    for ((REP = 0; REP < ${#REPOSITORY_NAMES[@]}; REP++)); do

        # concatenate paths to give the correct install path
        THIS_REP=${REPOSITORY_NAMES[${REP}]}
        THIS_PATH=${ANALYSIS_PATH}${REPOSITORY_RELATIVE_PATHS[$REP]}
        THIS_SOURCE=${REPOSITORY_SOURCE[$REP]}

        if [[ -d ${THIS_PATH} ]]; then
            cd "${THIS_PATH}" || exit
            echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
            echo "fetching branch ${THIS_PATH}"
            git fetch --all

            # only checkout if the branch exists
            if [[ "$(git ls-remote --heads "${THIS_SOURCE}/${THIS_REP}".git "${GIT_RELEASE}" | wc -l)" -eq "1" ]]; then
                echo "checkout branch ${THIS_PATH} to ${GIT_RELEASE}"
                git checkout "${GIT_RELEASE}"
                echo "reseting branch ${THIS_PATH} to origin/${GIT_RELEASE}"
                git reset --hard origin/"${GIT_RELEASE}"
            else
                echo "branch doesn't exists: ${THIS_SOURCE}/${THIS_REP}.git ${GIT_RELEASE}"
            fi
        fi
    done
fi

echo "done - please run internal/scripts/installSymbolicLinks.sh to finish"
