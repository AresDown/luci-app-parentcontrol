#
# Copyright 2019-2024 sirpdboy
#
# This is free software, licensed under the Apache License, Version 2.0 .
#

include $(TOPDIR)/rules.mk

NAME:=parentcontrol
PKG_NAME:=luci-app-$(NAME)
PKG_VERSION:=1.7.5
PKG_RELEASE:=20260608
PKG_LICENSE:=Apache-2.0

define Package/$(PKG_NAME)
  SECTION:=luci
  CATEGORY:=LuCI
  SUBMENU:=3. Applications
  TITLE:=LuCI support for Parent Control
  DEPENDS:=+nftables
endef

define Package/$(PKG_NAME)/conffiles
/etc/config/parentcontrol
endef

define Package/$(PKG_NAME)/install
    $(INSTALL_DIR) $(1)/etc/config
    $(INSTALL_CONF) ./root/etc/config/parentcontrol $(1)/etc/config/parentcontrol

    $(INSTALL_DIR) $(1)/etc/init.d
    $(INSTALL_BIN) ./root/etc/init.d/parentcontrol $(1)/etc/init.d/parentcontrol

endef

define Package/$(PKG_NAME)/postinst
#!/bin/sh
[ -x /etc/init.d/parentcontrol ] || chmod 755 /etc/init.d/parentcontrol
exit 0
endef

include $(TOPDIR)/feeds/luci/luci.mk

# call BuildPackage - OpenWrt buildroot signature
