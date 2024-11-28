#
#  Copyright (C) 2014-2024 BlissRoms Project
#
#  SPDX-License-Identifier: Apache-2.0
#

# Inherit from those products. Most specific first.
$(call inherit-product, $(SRC_TARGET_DIR)/product/core_64_bit.mk)
$(call inherit-product, $(SRC_TARGET_DIR)/product/full_base_telephony.mk)
$(call inherit-product, $(SRC_TARGET_DIR)/product/non_ab_device.mk)

# Inherit from the common Open Source product configuration
$(call inherit-product, $(SRC_TARGET_DIR)/product/aosp_base_telephony.mk)

# Inherit some common RisingOS stuff.
$(call inherit-product, vendor/bliss/config/common_full_phone.mk)

# Inherit from device makefile.
$(call inherit-product, $(LOCAL_PATH)/device.mk)

BLISS_BUILDTYPE := UNOFFICIAL
WITH_GMS := true
TARGET_STOCK_GAPPS := true
TARGET_INCLUDE_PIXEL_CHARGER := true
TARGET_SUPPORTS_QUICK_TAP := true
TARGET_SUPPORTS_NEXT_GEN_ASSISTANT := true

# Boot Animation Resolution
TARGET_BOOT_ANIMATION_RES := 1080

# Device Information
PRODUCT_DEVICE := salaa
PRODUCT_NAME := bliss_$(PRODUCT_DEVICE)
PRODUCT_BRAND := realme
PRODUCT_MANUFACTURER := $(PRODUCT_BRAND)
PRODUCT_MODEL := realme 7/Narzo 20 Pro/Narzo 30 4G

PRODUCT_GMS_CLIENTID_BASE := android-$(PRODUCT_BRAND)

PRODUCT_SYSTEM_NAME := RMX2156
PRODUCT_SYSTEM_DEVICE := RMX2156L1

PRODUCT_BUILD_PROP_OVERRIDES += \
    BuildDesc="sys_mssi_64_cn_armv82-user 12 SP1A.210812.016 1711679158901 release-keys" \
    DeviceName=$(PRODUCT_SYSTEM_DEVICE) \
    DeviceProduct=$(PRODUCT_SYSTEM_NAME) \
    SystemDevice=$(PRODUCT_SYSTEM_DEVICE) \
    SystemName=$(PRODUCT_SYSTEM_NAME) \
    BuildFingerprint="realme/RMX2156/RMX2156L1:12/SP1A.210812.016/Q.174ebd4_fa4d:user/release-keys"
