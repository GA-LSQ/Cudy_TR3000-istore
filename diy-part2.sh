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



curl -o package/base-files/files/etc/banner https://raw.githubusercontent.com/istoreos/istoreos/refs/heads/istoreos-22.03/package/base-files/files/etc/banner

# 配置WiFi：2.4GHz和5GHz分开，无密码
# 2.4GHz WiFi 配置
uci set wireless.@wifi-device[0].txpower=20
uci set wireless.@wifi-device[0].htmode=HT40

# 创建2.4GHz无密码网络
uci set wireless.@wifi-iface[0].device=radio0
uci set wireless.@wifi-iface[0].mode=ap
uci set wireless.@wifi-iface[0].ssid=Cudy-2.4G
uci set wireless.@wifi-iface[0].encryption=none
uci set wireless.@wifi-iface[0].network=lan

# 5GHz WiFi 配置
uci set wireless.@wifi-device[1].txpower=20
uci set wireless.@wifi-device[1].htmode=VHT80

# 创建5GHz无密码网络
uci set wireless.@wifi-iface[1].device=radio1
uci set wireless.@wifi-iface[1].mode=ap
uci set wireless.@wifi-iface[1].ssid=Cudy-5G
uci set wireless.@wifi-iface[1].encryption=none
uci set wireless.@wifi-iface[1].network=lan

# 提交WiFi配置
uci commit wireless
