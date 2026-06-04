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
#uci set wireless.@wifi-device[0].txpower=20
uci set wireless.@wifi-device[0].htmode=HT40

# 创建2.4GHz无密码网络
uci set wireless.@wifi-iface[0].device=radio0
uci set wireless.@wifi-iface[0].mode=ap
uci set wireless.@wifi-iface[0].ssid=Cudy-2.4G
uci set wireless.@wifi-iface[0].encryption=none
uci set wireless.@wifi-iface[0].network=lan

# 5GHz WiFi 配置
#uci set wireless.@wifi-device[1].txpower=20
uci set wireless.@wifi-device[1].htmode=VHT80

# 创建5GHz无密码网络
uci set wireless.@wifi-iface[1].device=radio1
uci set wireless.@wifi-iface[1].mode=ap
uci set wireless.@wifi-iface[1].ssid=Cudy-5G
uci set wireless.@wifi-iface[1].encryption=none
uci set wireless.@wifi-iface[1].network=lan

# 提交WiFi配置
uci commit wireless

# 设置默认登录密码为admin
# 获取admin用户的密码哈希值（密码:admin）
ADMIN_PASS='$1$15u8qIKT$CKaF1XmvOUZfQlQx8TTbO0'

# 修改shadow文件中的root和admin用户密码
sed -i "s|^root:[^:]*:|root:${ADMIN_PASS}:|" package/base-files/files/etc/shadow 2>/dev/null || true

# 确保root用户密码被设置
mkdir -p package/base-files/files/etc
if ! grep -q "^root:" package/base-files/files/etc/shadow 2>/dev/null; then
    echo "root:${ADMIN_PASS}:19000:0:99999:7:::" >> package/base-files/files/etc/shadow
fi

# 配置自定义OPKG Feed源
mkdir -p package/base-files/files/etc/opkg
echo "src/gz dllkids_feed https://down.dllkids.xyz/openwrt-feed/jell/24.10/aarch64_cortex-a53" >> package/base-files/files/etc/opkg/customfeeds.conf

# 集成预编译 ipk（支持 tar.gz 格式）
IPK_FILE="$GITHUB_WORKSPACE/package/luci-app-button-automation_0_all.ipk"
if [ -f "$IPK_FILE" ]; then
    echo ">>> 发现 ipk，正在解包集成..."
    mkdir -p /tmp/ipk_extract
    cd /tmp/ipk_extract
    tar -xzf "$IPK_FILE"                     # 解出 control.tar.gz 和 data.tar.gz
    tar -xzf data.tar.gz -C "$GITHUB_WORKSPACE/openwrt/files"
    cd /
    rm -rf /tmp/ipk_extract
    echo ">>> 集成完成，插件已放入 openwrt/files/"
else
    echo ">>> 未找到 ipk 文件，跳过"
fi
