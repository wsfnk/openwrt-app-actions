

include $(TOPDIR)/rules.mk

PKG_VERSION:=1.1.3-20231208
PKG_RELEASE:=

LUCI_TITLE:=LuCI support for getlink
LUCI_PKGARCH:=all
LUCI_DEPENDS:=+lsblk +docker +luci-lib-taskd

define Package/luci-app-getlink/conffiles
/etc/config/getlink
endef

include $(TOPDIR)/feeds/luci/luci.mk

# call BuildPackage - OpenWrt buildroot signature
