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

# Modify default IP
sed -i 's/192.168.1.1/192.168.0.200/g' package/base-files/files/bin/config_generate

# Modify default theme
#sed -i 's/luci-theme-bootstrap/luci-theme-argon/g' feeds/luci/collections/luci/Makefile

# Modify hostname
#sed -i 's/OpenWrt/P3TERX-Router/g' package/base-files/files/bin/config_generate

# ========== 强制设置为 armvirt 目标 ==========
echo "=== Forcing armvirt target configuration ==="

# 删除所有目标架构配置
sed -i '/CONFIG_TARGET_/d' .config

# 写入正确的 armvirt 配置
cat > .config << 'EOF'
CONFIG_TARGET_armvirt=y
CONFIG_TARGET_armvirt_64=y
CONFIG_TARGET_armvirt_64_DEVICE_generic=y
EOF

# 添加虚拟化驱动
cat >> .config << 'EOF'
CONFIG_PACKAGE_kmod-vmxnet3=y
CONFIG_PACKAGE_kmod-virtio=y
CONFIG_PACKAGE_kmod-virtio-net=y
CONFIG_PACKAGE_kmod-virtio-pci=y
CONFIG_PACKAGE_kmod-scsi-core=y
CONFIG_PACKAGE_kmod-scsi-virtio=y
CONFIG_PACKAGE_kmod-virtio-scsi=y
EOF

# 禁用 GRUB
sed -i '/CONFIG_GRUB/d' .config
sed -i '/CONFIG_PACKAGE_grub2/d' .config

# 重新生成配置
make defconfig

# 验证目标
echo "=== Current target ==="
grep "^CONFIG_TARGET_armvirt" .config
grep "^CONFIG_TARGET_x86" .config || echo "No x86 target (good)"

echo "Configuration fix applied"
