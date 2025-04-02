#!/bin/bash
# Author: Vincenzo Merola <vincenzo.merola2@unina.it>

# Description:
# This script downloads Vitis HLS accelerators sources and flattens them into a build/ directory.

# To execute: ./fetch_sources.sh
# To execute you need:
#   git
#   Vitis 2024.2

# Colors
RED='\033[1;31m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

GIT_URL=https://github.com/Vincenzo0709/Vitis_HLS_accelerators.git
GIT_TAG=main
CLONE_DIR=Vitis_HLS_accelerators

declare -A accel_tags
accel_tags=(["vdotprod"]="v1.0" ["matmul"]="v1.0")

# Display help
Help()
{
   echo
   echo "This script downloads Vitis HLS accelerators sources and flattens them into build/ directory."
   echo
   echo "Syntax: fetch_source.sh [--option]"
   echo
   echo "options:"
   echo "-a | --all             Builds all accelerators"
   echo "-h | --help            Prints help"
   echo
}

GitFlatten()
{
    
    BUILD="`pwd -P`/build"

    # Cloning repo and updating submodules to specific tag
    printf "${YELLOW}[FETCH_SOURCES] Cloning source repository${NC}\n"
    git clone ${GIT_URL} -b ${GIT_TAG} ${CLONE_DIR}
    cd ${CLONE_DIR}
    git submodule update --recursive

    for i in ${ACC}; do

        cd accel/$i/
        git fetch
        git checkout ${accel_tags[$i]}
        cd ${WORK_DIR}
        
    done


    # Clone Bender (future development)
    # printf "${YELLOW}[FETCH_SOURCES] Download Bender${NC}\n"
    # curl --proto '=https' --tlsv1.2 https://pulp-platform.github.io/bender/init -sSf | sh

    # Copying all build files
    printf "${YELLOW}[FETCH_SOURCES] Copying all sources into rtl${NC}\n"
    for i in ${ACC}; do

        mkdir -p ${BUILD}/${i}/ip ${BUILD}/${i}/rtl

        # Accessing each chosen accelerator and building
        cd accel/${i}
        ./scripts/fetch_sources.sh

        # Copying results in build/ directory
        cp -r build/* ${BUILD}/$i

    done


    # Deleting the cloned repo
    printf "${YELLOW}[FETCH_SOURCES] Cleaning all artifacts${NC}\n"
    sudo rm -r ${CLONE_DIR}
    printf "${GREEN}[FETCH_SOURCES] Completed${NC}\n"

}


OPTS=$(getopt -o ha --long,all help -n 'fetch_sources.sh' -- "$@")
eval set -- "$OPTS"

if [ "$OPTS" != " --" ]; then
    while true; do
        case "$1" in
            -h | --help) 
                # Print help
                Help
                exit 0
                ;;
            -a | --all)
                # All accelerators
                ACC="vdotprod matmul"
                shift
                break
                ;;
            --)
                shift
                break
                ;;
            ?)
                # Unrecognized options
                echo "Invalid option: -${OPTARG}."
                exit 1
                ;;
        esac
    done
fi


# Moving to right directory (if you cloned the whole repository instead of using only fetch_sources.sh)
cd "$(dirname "$0")" ; printf "\n${GREEN}[FETCH_SOURCES] Starting from directory `pwd -P`${NC}\n"
WORK_DIR=`pwd -P`
if [ "$(basename `pwd -P`)" == "scripts" ]; then
    cd .. ; printf "\n${GREEN}[FETCH_SOURCES] Moving to directory `pwd -P`${NC}\n"
    WORK_DIR=`pwd -P`
    Flatten
else
    GitFlatten
fi

