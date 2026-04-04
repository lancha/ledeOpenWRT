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

# 1. 完全删除旧配置（重要！）
rm -f .config

# 2. 写入基础 armvirt 配置
cat > .config << 'EOF'
CONFIG_TARGET_armvirt=y
CONFIG_TARGET_armvirt_64=y
CONFIG_TARGET_armvirt_64_DEVICE_generic=y
EOF

# 3. 运行 defconfig 生成基础配置
make defconfig

# 4. 删除所有 GRUB 和 x86 相关配置
echo "=== Removing GRUB and x86 configs ==="
sed -i '/CONFIG_GRUB/d' .config
sed -i '/CONFIG_PACKAGE_grub2/d' .config
sed -i '/CONFIG_TARGET_x86/d' .config

# 5. 添加虚拟化驱动
echo "=== Adding virtualization drivers ==="
cat >> .config << 'EOF'
CONFIG_PACKAGE_kmod-vmxnet3=y
CONFIG_PACKAGE_kmod-virtio=y
CONFIG_PACKAGE_kmod-virtio-net=y
CONFIG_PACKAGE_kmod-virtio-pci=y
CONFIG_PACKAGE_kmod-scsi-core=y
EOF

# 6. 再次运行 defconfig 合并配置
make defconfig

# 7. 最终清理（确保没有残留）
sed -i '/CONFIG_GRUB/d' .config
sed -i '/CONFIG_TARGET_x86/d' .config

# 8. 验证结果
echo "=== Final verification ==="
echo "armvirt targets:"
grep "^CONFIG_TARGET_armvirt" .config || echo "ERROR: armvirt not set!"
echo ""
echo "x86 targets (should be empty):"
grep "^CONFIG_TARGET_x86" .config || echo "No x86 targets (good)"
echo ""
echo "GRUB configs (should be empty):"
grep "^CONFIG_GRUB" .config || echo "No GRUB configs (good)"
echo ""
echo "Virtualization drivers:"
grep "^CONFIG_PACKAGE_kmod-virtio" .config || echo "Warning: virtio drivers not found"
grep "^CONFIG_PACKAGE_kmod-vmxnet3" .config || echo "Warning: vmxnet3 not found"

echo "Configuration fix applied"
