#!/bin/bash

build_fat_framework() {
    set -e
    set +u
    # Avoid recursively calling this script.
    if [[ $MASTER_SCRIPT_RUNNING ]]
    then
        exit 0
    fi
    set -u
    export MASTER_SCRIPT_RUNNING=1


    if [[ "$SDK_NAME" =~ ([A-Za-z]+) ]]
    then
        SDK_PLATFORM=${BASH_REMATCH[1]}
    else
        echo "Could not find platform name from SDK_NAME: $SDK_NAME"
        exit 1
    fi

    if [[ "$SDK_NAME" =~ ([0-9]+.*$) ]]
    then
        SDK_VERSION=${BASH_REMATCH[1]}
    else
        echo "Could not find sdk version from SDK_NAME: $SDK_NAME"
        exit 1
    fi

    if [[ "$SDK_PLATFORM" = "iphoneos" ]]
    then
        OTHER_PLATFORM=iphonesimulator
    else
        OTHER_PLATFORM=iphoneos
    fi

    if [[ "$BUILT_PRODUCTS_DIR" =~ (.*)-$SDK_PLATFORM$ ]]
    then
        OTHER_BUILT_PRODUCTS_DIR="${BASH_REMATCH[1]}-${OTHER_PLATFORM}"
        UNIVERSAL_PRODUCTS_DIR="${BASH_REMATCH[1]}-Universal-${SDK_PLATFORM}"
    else
        echo "Could not find platform name from build products directory: $BUILT_PRODUCTS_DIR"
        exit 1
    fi



    # begin build fat lib
    TARGET_NAME="$1"
    FRAMEWORK_NAME="${TARGET_NAME}.framework"
    EXECUTABLE_PATH="${FRAMEWORK_NAME}/${TARGET_NAME}"

    # Build the other platform.
    xcodebuild -project "${PROJECT_FILE_PATH}" -target "${TARGET_NAME}" -configuration "${CONFIGURATION}" -sdk ${OTHER_PLATFORM}${SDK_VERSION} BUILD_DIR="${BUILD_DIR}" OBJROOT="${OBJROOT}" BUILD_ROOT="${BUILD_ROOT}" SYMROOT="${SYMROOT}" $ACTION

    if [ ! -d "${UNIVERSAL_PRODUCTS_DIR}" ]; then
        mkdir "${UNIVERSAL_PRODUCTS_DIR}"
    fi
    cp -r "${TARGET_BUILD_DIR}/${FRAMEWORK_NAME}" "${UNIVERSAL_PRODUCTS_DIR}/"

    # Smash the two libraries into one fat binary
    lipo -create "${BUILT_PRODUCTS_DIR}/${EXECUTABLE_PATH}" "${OTHER_BUILT_PRODUCTS_DIR}/${EXECUTABLE_PATH}" -output "${UNIVERSAL_PRODUCTS_DIR}/${EXECUTABLE_PATH}"
}


while getopts ":F:" optname
do
    case "$optname" in
        "F")
            echo "input filename is $OPTARG"
            build_fat_framework "$OPTARG"
            ;;
        "?")
            echo "Unknown option $OPTARG"
            ;;
        ":")
            echo "No argument value for option $OPTARG"
            ;;
        *)
            echo "Unknown error while processing options"
            ;;
    esac
done
