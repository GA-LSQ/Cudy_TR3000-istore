#!/bin/bash
#
# https://github.com/P3TERX/Actions-OpenWrt
# File name: diy-part2.sh
# Description: OpenWrt DIY script part 2 (After Update feeds)
#
# Copyright (c) 2019-2024 P3TERX <https://p3terx.com>
#
# This is free software, licensed under the MIT License.
# See /LICENSE for more information.
#

# Modify luci-app
#git clone https://github.com/theosoft-git/luci-app-easymesh.git package/luci-app-easymesh

# Modify default theme
sed -i 's/luci-theme-bootstrap/luci-theme-argon/g' feeds/luci/collections/luci/Makefile

# Modify default IP
sed -i 's/192.168.1.1/192.168.10.1/g' package/base-files/files/bin/config_generate

# Modify hostname
sed -i 's/LEDE/Cudy/g' package/base-files/files/bin/config_generate
sed -i 's/LEDE/Cudy/g' package/base-files/files/etc/init.d/system
sed -i 's/LEDE/Cudy/g' package/kernel/mac80211/files/lib/wifi/mac80211.sh
sed -i 's/LEDE/Cudy/g' package/base-files/luci2/bin/config_generate
sed -i 's/LEDE/Cudy/g' package/lean/default-settings/files/zzz-default-settings

# Configure WiFi SSID with auto channel and maximum bandwidth
cat >> package/base-files/files/etc/config/wireless <<EOF

config wifi-device 'radio0'
	option type 'mac80211'
	option hwmode '11a'
	option path 'pci0000:00/0000:00:00.0'
	option channel 'auto'
	option htmode 'VHT160'

config wifi-iface 'wifinet0'
	option device 'radio0'
	option network 'lan'
	option ssid 'Cudy-5G'
	option encryption 'none'

config wifi-device 'radio1'
	option type 'mac80211'
	option hwmode '11g'
	option path 'pci0000:00/0000:00:01.0'
	option channel 'auto'
	option htmode 'HT40'

config wifi-iface 'wifinet1'
	option device 'radio1'
	option network 'lan'
	option ssid 'Cudy-2.4G'
	option encryption 'none'
EOF

curl -o package/base-files/files/etc/banner https://raw.githubusercontent.com/istoreos/istoreos/refs/heads/istoreos-22.03/package/base-files/files/etc/banner
