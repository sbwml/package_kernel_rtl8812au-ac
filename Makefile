include $(TOPDIR)/rules.mk

PKG_NAME:=rtl8812au-ac
PKG_RELEASE:=1

PKG_LICENSE:=GPLv2
PKG_LICENSE_FILES:=

PKG_SOURCE_URL:=https://github.com/aircrack-ng/rtl8812au.git
PKG_SOURCE_PROTO:=git
PKG_SOURCE_DATE:=2023-07-23
PKG_SOURCE_VERSION:=04f600ee54a414b871aea509fcd4709838c8c522
PKG_MIRROR_HASH:=df8aa45fb2bc2bc706b8fe49b4b7c4216b64232286845bb7dc231d0be309ccac

# PKG_MAINTAINER:=
PKG_BUILD_PARALLEL:=1

STAMP_CONFIGURED_DEPENDS := $(STAGING_DIR)/usr/include/mac80211-backport/backport/autoconf.h

include $(INCLUDE_DIR)/kernel.mk
include $(INCLUDE_DIR)/package.mk

define KernelPackage/rtl8812au-ac
  SUBMENU:=Wireless Drivers
  TITLE:=Realtek rtl8812au/21au and rtl8814au driver
  DEPENDS:=+kmod-cfg80211 +kmod-usb-core +@DRIVER_11N_SUPPORT +@DRIVER_11AC_SUPPORT
  KCONFIG:=CONFIG_PLATFORM_I386_PC=n
  FILES:=\
	$(PKG_BUILD_DIR)/rtl8812au.ko
  AUTOLOAD:=$(call AutoProbe,rtl8812au)
endef

NOSTDINC_FLAGS := \
	-I$(PKG_BUILD_DIR) \
	-I$(PKG_BUILD_DIR)/include \
	-I$(STAGING_DIR)/usr/include/mac80211-backport \
	-I$(STAGING_DIR)/usr/include/mac80211-backport/uapi \
	-I$(STAGING_DIR)/usr/include/mac80211 \
	-I$(STAGING_DIR)/usr/include/mac80211/uapi \
	-include backport/autoconf.h \
	-include backport/backport.h \
	-Wno-error=address

ifeq (,$(findstring clang,$(KERNEL_CC)))
NOSTDINC_FLAGS += \
	-Wno-error=stringop-overread
endif

NOSTDINC_FLAGS += -DCONFIG_IOCTL_CFG80211 -DRTW_USE_CFG80211_STA_EVENT \
	-D_LINUX_BYTEORDER_SWAB_H -DBUILD_OPENWRT -DRTW_SINGLE_WIPHY \
	-DBUILD_OPENWRT
ifeq ($(CONFIG_BIG_ENDIAN), y)
NOSTDINC_FLAGS += -DCONFIG_BIG_ENDIAN
endif
ifeq ($(CONFIG_LITTLE_ENDIAN), y)
NOSTDINC_FLAGS += -DCONFIG_LITTLE_ENDIAN
endif

PKG_MAKE_FLAGS += USER_MODULE_NAME=rtl8812au
PKG_MAKE_FLAGS += USER_DRV_NAME=rtl8812au
KERNEL_MAKE_FLAGS += CONFIG_88XXAU=m

define Build/Compile
	+$(MAKE) $(PKG_JOBS) -C "$(LINUX_DIR)" \
		$(KERNEL_MAKE_FLAGS) \
		$(PKG_MAKE_FLAGS) \
		M="$(PKG_BUILD_DIR)" \
		NOSTDINC_FLAGS="$(NOSTDINC_FLAGS)" \
		modules
endef

$(eval $(call KernelPackage,rtl8812au-ac))
