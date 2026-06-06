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
git clone https://github.com/timsaya/luci-app-bandix package/luci-app-bandix
git clone https://github.com/timsaya/openwrt-bandix package/openwrt-bandix
git clone https://github.com/sirpdboy/luci-app-partexp package/luci-app-partexp
git clone https://github.com/sirpdboy/luci-app-advancedplus package/luci-app-advancedplus

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

#兼容immortalwrt
#sed -i 's/immortalwrt/Cudy/g' package/base-files/files/bin/config_generate
#sed -i 's/immortalwrt/Cudy/g' package/base-files/files/etc/init.d/system
#sed -i 's/immortalwrt/Cudy/g' package/kernel/mac80211/files/lib/wifi/mac80211.sh


curl -o package/base-files/files/etc/banner https://raw.githubusercontent.com/istoreos/istoreos/refs/heads/istoreos-22.03/package/base-files/files/etc/banner


# 配置自定义OPKG Feed源
#mkdir -p package/base-files/files/etc/opkg
#echo "src/gz kwrt_kiddin9 https://dl.openwrt.ai/releases/24.10/packages/aarch64_cortex-a53/kiddin9" >> package/base-files/files/etc/opkg/customfeeds.conf


#集成预编译ipk（支持tar.gz格式）
IPK_FILE="$GITHUB_WORKSPACE/package/luci-app-button-automation_0_all.ipk"
if [ -f "$IPK_FILE" ]; then
    echo ">>> 发现ipk，正在解包集成..."
    mkdir -p /tmp/ipk_extract
    cd /tmp/ipk_extract
    tar -xzf "$IPK_FILE"                     # 解出 control.tar.gz 和 data.tar.gz
    # 确保目标目录存在
    mkdir -p "$GITHUB_WORKSPACE/openwrt/files"
    tar -xzf data.tar.gz -C "$GITHUB_WORKSPACE/openwrt/files"
    cd /
    rm -rf /tmp/ipk_extract
    echo ">>> 集成完成，插件已放入 openwrt/files/"
else
    echo ">>> 未找到ipk文件，跳过"
fi
