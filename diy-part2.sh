#!/bin/bash

# Modify default IP
sed -i 's/192.168.1.1/192.168.0.200/g' package/base-files/files/bin/config_generate

# ========== 强制设置为 armvirt 目标 ==========
echo "=== Forcing armvirt target configuration ==="

# 1. 完全删除旧配置
rm -f .config

# 2. 写入完整的 armvirt 配置（不使用 make defconfig）
cat > .config << 'EOF'
CONFIG_TARGET_armvirt=y
CONFIG_TARGET_armvirt_64=y
CONFIG_TARGET_armvirt_64_DEVICE_generic=y
CONFIG_TARGET_BOARD="armvirt"
CONFIG_TARGET_SUBTARGET="64"
CONFIG_TARGET_PROFILE="DEVICE_generic"
CONFIG_TARGET_ARCH_PACKAGES="aarch64_generic"
CONFIG_ARCH="aarch64"
CONFIG_TARGET_ROOTFS_EXT4FS=y
CONFIG_TARGET_ROOTFS_TARGZ=y
CONFIG_TARGET_IMAGES_GZIP=y

# 禁用所有 GRUB 和 VMDK
# CONFIG_GRUB_IMAGES is not set
# CONFIG_GRUB_EFI_IMAGES is not set
# CONFIG_VMDK_IMAGES is not set

# 添加虚拟化驱动
CONFIG_PACKAGE_kmod-vmxnet3=y
CONFIG_PACKAGE_kmod-virtio=y
CONFIG_PACKAGE_kmod-virtio-net=y
CONFIG_PACKAGE_kmod-virtio-pci=y
CONFIG_PACKAGE_kmod-scsi-core=y
EOF

# 3. 运行 defconfig 补充依赖
make defconfig

# 4. 再次确保 armvirt 存在（防止被覆盖）
echo "CONFIG_TARGET_armvirt=y" >> .config
echo "CONFIG_TARGET_armvirt_64=y" >> .config
echo "CONFIG_TARGET_armvirt_64_DEVICE_generic=y" >> .config

# 5. 删除所有残留的 x86 和 GRUB 配置
sed -i '/CONFIG_TARGET_x86/d' .config
sed -i '/CONFIG_GRUB/d' .config
sed -i '/CONFIG_PACKAGE_grub2/d' .config
sed -i '/CONFIG_VMDK/d' .config

# 6. 最终验证
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
echo "VMDK configs (should be empty):"
grep "^CONFIG_VMDK" .config || echo "No VMDK configs (good)"

echo "Configuration fix applied"
