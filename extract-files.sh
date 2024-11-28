#!/bin/bash
#
#  Copyright (C) 2014-2024 BlissRoms Project
#
#  SPDX-License-Identifier: Apache-2.0
#

set -e

DEVICE=salaa
VENDOR=realme

# Load extract_utils and do some sanity checks
MY_DIR="${BASH_SOURCE%/*}"
if [[ ! -d "${MY_DIR}" ]]; then MY_DIR="${PWD}"; fi

ANDROID_ROOT="${MY_DIR}/../../.."

# If XML files don't have comments before the XML header, use this flag
# Can still be used with broken XML files by using blob_fixup
export TARGET_DISABLE_XML_FIXING=true

HELPER="${ANDROID_ROOT}/tools/extract-utils/extract_utils.sh"
if [ ! -f "${HELPER}" ]; then
    echo "Unable to find helper script at ${HELPER}"
    exit 1
fi
source "${HELPER}"

# Default to sanitizing the vendor folder before extraction
CLEAN_VENDOR=true

KANG=
SECTION=

while [ "${#}" -gt 0 ]; do
    case "${1}" in
        -n | --no-cleanup )
                CLEAN_VENDOR=false
                ;;
        -k | --kang )
                KANG="--kang"
                ;;
        -s | --section )
                SECTION="${2}"; shift
                CLEAN_VENDOR=false
                ;;
        * )
                SRC="${1}"
                ;;
    esac
    shift
done

function blob_fixup {
    case "$1" in
        system_ext/lib64/libsource.so)
            grep -q libshim_ui.so "$2" || "$PATCHELF" --add-needed libshim_ui.so "$2"
            ;;
        vendor/bin/hw/android.hardware.media.c2@1.2-mediatek|vendor/bin/hw/android.hardware.media.c2@1.2-mediatek-64b)
            "${PATCHELF}" --add-needed "libstagefright_foundation-v33.so" "${2}"
            ;;
        vendor/lib64/mediadrm/libwvdrmengine.so|vendor/lib64/libwvhidl.so)
            [ "$2" = "" ] && return 0
            grep -q "libcrypto-v33.so" "${2}" || "${PATCHELF}" --replace-needed "libcrypto.so" "libcrypto-v33.so" "$2"
            ;;
        *)
            return 1
            ;;
        vendor/bin/mnld|vendor/lib*/libcam.utils.sensorprovider.so|vendor/lib*/libaalservice.so|vendor/lib64/hw/android.hardware.sensors@2.X-subhal-mediatek.so)
            "${PATCHELF}" --replace-needed "libsensorndkbridge.so" "libsensorndkbridge-hidl.so" "$2"
            ;;
        vendor/lib64/libwifi-hal-mtk.so)
            "${PATCHELF}" --set-soname "libwifi-hal-mtk.so" "${2}"
            ;;
        vendor/lib64/hw/android.hardware.camera.provider@2.6-impl-mediatek.so)
            grep -q "libcamera_metadata_shim.so" "${2}" || "${PATCHELF}" --add-needed "libcamera_metadata_shim.so" "${2}"
            "${PATCHELF}" --replace-needed "libutils.so" "libutils-v32.so" "${2}"
            ;;
        vendor/lib64/libmtkcam_featurepolicy.so)
            # evaluateCaptureConfiguration()
            sed -i "s/\x34\xE8\x87\x40\xB9/\x34\x28\x02\x80\x52/" "$2"
            ;;
        vendor/lib*/hw/vendor.mediatek.hardware.pq@2.13-impl.so|vendor/lib*/libmtkcam_stdutils.so)
            "${PATCHELF}" --replace-needed "libutils.so" "libutils-v32.so" "${2}"
            ;;
        vendor/lib*/hw/audio.primary.mediatek.so)
            "${PATCHELF}" --replace-needed "libalsautils.so" "libalsautils-v32.so" "${2}"
            "${PATCHELF}" --replace-needed "libutils.so" "libutils-v32.so" "${2}"
            "${PATCHELF}" --replace-needed "libhidlbase.so" "libhidlbase-v32.so" "${2}"
            "${PATCHELF}" --replace-needed "libbinder.so" "libbinder-v32.so" "${2}"
            "${PATCHELF}" --add-needed "libstagefright_foundation-v33.so" "${2}"
            ;;
        vendor/lib*/libalsautils-v32.so)
            "${PATCHELF}" --set-soname "$(basename "${1}")" "${2}"
            ;;
        odm/etc/init/vendor.oplus.hardware.biometrics.fingerprint@2.1-service.rc)
            sed -i "8i\    task_profiles ProcessCapacityHigh MaxPerformance" "${2}"
            ;;
        vendor/etc/vintf/manifest/manifest_media_c2_V1_2_default.xml)
        sed -i 's/1.1/1.2' "$2"
        ;;
    esac
}

if [ -z "${SRC}" ]; then
    SRC="adb"
fi

# Initialize the helper
setup_vendor "${DEVICE}" "${VENDOR}" "${ANDROID_ROOT}" false "${CLEAN_VENDOR}"

extract "${MY_DIR}/proprietary-files.txt" "${SRC}" "${KANG}" --section "${SECTION}"

"${MY_DIR}/setup-makefiles.sh"
