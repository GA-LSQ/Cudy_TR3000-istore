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
git clone https://github.com/vernesong/OpenClash package/luci-app-openclash

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


# 创建首次启动脚本目录
mkdir -p package/base-files/files/etc/rc.d

# 写入脚本
cat > package/base-files/files/etc/rc.d/S99openwrt-feed-setup << 'EOF'
#!/bin/sh
# OpenWrt Feed Setup - 首次启动且联网成功后执行一次

MARKER_FILE="/etc/.openwrt-feed-setup-done"

# 已经执行过，直接退出
[ -f "$MARKER_FILE" ] && {
    logger -t openwrt-feed-setup "Already executed, skipping."
    exit 0
}

logger -t openwrt-feed-setup "Waiting for network connection..."

# 网络检测配置
MAX_WAIT=600        # 最多等待600秒
INTERVAL=2         # 每2秒检测一次
WAITED=0

# 检测网络连通性
is_network_ready() {
    # 方法1：ping 公共DNS
    ping -q -c 1 -W 2 8.8.8.8 >/dev/null 2>&1 && return 0
    ping -q -c 1 -W 2 114.114.114.114 >/dev/null 2>&1 && return 0
    
    # 方法2：检查默认网关
    ip route | grep -q 'default via' && return 0
    
    return 1
}

# 循环等待网络就绪
while [ $WAITED -lt $MAX_WAIT ]; do
    if is_network_ready; then
        logger -t openwrt-feed-setup "Network is up. Starting setup..."
        
        # 执行你的安装命令
        wget -qO- https://down.dllkids.xyz/openwrt-feed/openwrt-feed-setup.sh | sh
        
        # 标记已完成（无论安装成功或失败，都避免重复尝试）
        touch "$MARKER_FILE"
        
        logger -t openwrt-feed-setup "Setup completed."
        exit 0
    fi
    
    sleep $INTERVAL
    WAITED=$((WAITED + INTERVAL))
done

# 超时后未联网：本次不执行，下次重启再尝试
logger -t openwrt-feed-setup "Network not ready after ${MAX_WAIT}s, will retry on next boot."
exit 1
EOF

# 赋予执行权限
chmod +x package/base-files/files/etc/rc.d/S99openwrt-feed-setup

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
