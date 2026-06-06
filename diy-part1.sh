#!/bin/bash
#
# https://github.com/P3TERX/Actions-OpenWrt
# File name: diy-part1.sh
# Description: OpenWrt DIY script part 1 (Before Update feeds)
#
# Copyright (c) 2019-2024 P3TERX <https://p3terx.com>
#
# This is free software, licensed under the MIT License.
# See /LICENSE for more information.
#

# Uncomment a feed source

# Add a feed source
echo 'src-git nas https://github.com/linkease/nas-packages.git;master' >> feeds.conf.default
echo 'src-git nas_luci https://github.com/linkease/nas-packages-luci.git;main' >> feeds.conf.default
echo 'src-git istore https://github.com/linkease/istore;main' >> feeds.conf.default

#sed -i '$a src-git smpackage https://github.com/kenzok8/small-package' feeds.conf.default
sed -i '1i src-git kenzo https://github.com/kenzok8/openwrt-packages' feeds.conf.default
sed -i '2i src-git small https://github.com/kenzok8/small' feeds.conf.default

# 解决rust相关报错
sed -i 's/ci-llvm=true/ci-llvm=false/g' feeds/packages/lang/rust/Makefile

# openclash
mkdir -p package/luci-app-openclash
cd package/luci-app-openclash
git init
git remote add origin https://github.com/vernesong/OpenClash.git
git config core.sparsecheckout true
echo "luci-app-openclash" >> .git/info/sparse-checkout
git pull --depth 1 origin master
cd ../../../


#删除默认password密码
#sed -i "/CYXluq4wUazHjmCDBCqXF/d" package/lean/default-settings/files/zzz-default-settings




# 创建 uci-defaults 目录
mkdir -p package/base-files/files/etc/uci-defaults

# 写入脚本
cat > package/base-files/files/etc/uci-defaults/99-feed-setup << 'EOF'
#!/bin/sh
MARKER="/etc/.feed-setup-done"
[ -f "$MARKER" ] && exit 0

TIMEOUT=600
INTERVAL=2
ELAPSED=0
URL="https://down.dllkids.xyz/openwrt-feed/openwrt-feed-setup.sh"

can_reach_script() {
    wget --spider --timeout=3 --tries=1 "$URL" >/dev/null 2>&1
}

while [ $ELAPSED -lt $TIMEOUT ]; do
    if can_reach_script; then
        logger -t feed-setup "Script URL reachable. Running setup..."
        if wget -qO- "$URL" | sh; then
            logger -t feed-setup "Setup succeeded."
            touch "$MARKER"
            exit 0
        else
            logger -t feed-setup "Setup failed. Will retry next boot."
            exit 1
        fi
    fi
    sleep $INTERVAL
    ELAPSED=$((ELAPSED + INTERVAL))
done

logger -t feed-setup "Script URL not reachable after ${TIMEOUT}s. Will retry next boot."
exit 1
EOF

chmod +x package/base-files/files/etc/uci-defaults/99-feed-setup

# 设置首次启动脚本将密码改为 admin
mkdir -p package/base-files/files/etc/uci-defaults
cat > package/base-files/files/etc/uci-defaults/99_set_password << 'EOF'
#!/bin/sh
echo "password:admin" | chpasswd
exit 0
EOF
chmod +x package/base-files/files/etc/uci-defaults/99_set_password

