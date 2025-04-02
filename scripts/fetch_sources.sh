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

accel_tags=(["vdotprod"]="v1.0" ["matmul"]="v1.0")
ACC=("vdotprod" "matmul")

# Display help
Help() {

   cat << EOF

This script downloads Vitis HLS accelerators sources and flattens them into build/ directory."

Syntax: fetch_source.sh [OPTION] [ARGUMENT]"

Options:
    -s | --select           Selects only one accelerator to build
    -a | --all              Builds all accelerators
    -h | --help             Prints help

EOF

}

GitFlatten()
{
    printf "\n${GREEN}[FETCH_SOURCES_TOP] Fetching without git${NC}\n"
    BUILD="`pwd -P`/build"

    # Cloning repo and updating submodules to specific tag
    printf "\n${YELLOW}[FETCH_SOURCES_TOP] Cloning source repository${NC}\n"
    git clone ${GIT_URL} -b ${GIT_TAG} ${CLONE_DIR}
    cd ${CLONE_DIR}
    git submodule init
    git submodule update --recursive

    cd accel/
    for i in ${ACC[@]}; do

        printf "\n${YELLOW}[FETCH_SOURCES_TOP] Checking out %s to %s branch/tag${NC}\n" "$i" "${accel_tags[$i]}"
        cd $i/
        git fetch
        git checkout main
        git checkout ${accel_tags[$i]}

        # Accessing each chosen accelerator and building
        ./scripts/fetch_sources.sh

        # Copying results in build/ directory
        mkdir -p ${BUILD}/${i}/ip ${BUILD}/${i}/rtl
        cp -r hw/build/* ${BUILD}/$i
        cd ..
        
    done


    # Clone Bender (future development)
    # printf "${YELLOW}[FETCH_SOURCES] Download Bender${NC}\n"
    # curl --proto '=https' --tlsv1.2 https://pulp-platform.github.io/bender/init -sSf | sh

    # Deleting the cloned repo
    cd ${WORK_DIR}
    printf "\n${YELLOW}[FETCH_SOURCES_TOP] Cleaning all artifacts${NC}\n"
    sudo rm -r ${CLONE_DIR}
    printf "\n${GREEN}[FETCH_SOURCES_TOP] Completed${NC}\n"

}

Flatten()
{

    printf "\n${GREEN}[FETCH_SOURCES_TOP] Fetching without git${NC}\n"
    BUILD="`pwd -P`/build"

    # Updating submodules to specific tag
    cd accel/
    for i in ${ACC[@]}; do

        printf "\n${YELLOW}[FETCH_SOURCES_TOP] Checking out %s to %s branch/tag${NC}\n" "$i" "${accel_tags[$i]}"
        cd $i/
        git fetch
        git checkout main
        git checkout ${accel_tags[$i]}

        # Accessing each chosen accelerator and building
        ./scripts/fetch_sources.sh

        # Copying results in build/ directory
        mkdir -p ${BUILD}/${i}/ip ${BUILD}/${i}/rtl
        cp -r hw/build/* ${BUILD}/$i
        cd ..
        
    done


    # Clone Bender (future development)
    # printf "${YELLOW}[FETCH_SOURCES] Download Bender${NC}\n"
    # curl --proto '=https' --tlsv1.2 https://pulp-platform.github.io/bender/init -sSf | sh

    printf "\n${GREEN}[FETCH_SOURCES_TOP] Completed${NC}\n"

}

OPTS=$(getopt -o has: --long all,help,select: -n 'fetch_sources.sh' -- "$@")
eval set -- "$OPTS"

if [ "$OPTS" != " --" ]; then
    while true; do
        case "$1" in
            -h | --help) 
                # Print help
                Help
                exit 0
                ;;
            -s | --select)
                # Select only one accelerator
                sel=(false)
                for i in ${ACC[@]}; do
                    if [ "$2" = ${ACC[$i]} ]; then
                        sel=(true)
                        ACC_temp=($2)
                    fi
                done
                if ${sel}; then
                    echo ${sel}
                    echo "ERROR: invalid selection"
                    Help
                    exit 1
                fi
                ACC=${ACC_temp}
                shift 2
                break
                ;;
            -a | --all)
                # All accelerators
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
cd "$(dirname "$0")" ; printf "\n${GREEN}[FETCH_SOURCES_TOP] Starting from directory `pwd -P`${NC}\n"
WORK_DIR=`pwd -P`
if [ "$(basename `pwd -P`)" == "scripts" ]; then
    cd .. ; printf "\n${GREEN}[FETCH_SOURCES_TOP] Moving to directory `pwd -P`${NC}\n"
    WORK_DIR=`pwd -P`
    Flatten
else
    GitFlatten
fi