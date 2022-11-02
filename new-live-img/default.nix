# SPDX-FileCopyrightText: 2022 Unikie

{ config ? import ../../spectrum/nix/eval-config.nix {} }:

let
  inherit (config) pkgs;
  uboot = pkgs.callPackage ../bsp/imx8qm/imx-uboot.nix { inherit pkgs; };
  spectrum = import ../../spectrum/release/live { };
  kernel = spectrum.rootfs.kernel;
  appvm-user = pkgs.callPackage ../user-app-vm/default.nix { inherit config; };
  myextpart = with pkgs; runCommand "myext.ext4" {
    nativeBuildInputs = [ e2tools e2fsprogs util-linux tar2ext4 libguestfs libguestfs-appliance ];
  } ''
    export LIBGUESTFS_PATH=${libguestfs-appliance}/
    cp ${spectrum.EXT_FS} myext.ext4
    mkdir mp
    ${libguestfs}/bin/guestmount -a myext.ext4 -m /dev/sda --rw ./mp
    tar -C ${appvm-user} -c data | tar -C mp/svc -x
    ${libguestfs}/bin/guestunmount mp
    mv myext.ext4 $out
  '';
in

with pkgs;

spectrum.overrideDerivation (oldAttrs: {
  EXT_FS = myextpart;
  pname = "build/live.img";
  installPhase = ''
    runHook preInstall
    dd if=/dev/zero bs=1M count=6 >> $pname
    partnum=$(sfdisk --json $pname | grep "node" | wc -l)
    while [ $partnum -gt 0 ]; do
      echo '+6M,' | sfdisk --move-data $pname -N $partnum
      partnum=$((partnum-1))
    done
    dd if=$uboot/flash.bin of=$pname bs=1k seek=32 conv=notrunc
    ESP_OFFSET=$(sfdisk --json $pname | jq -r '
      # Partition type GUID identifying EFI System Partitions
      def ESP_GUID: "C12A7328-F81F-11D2-BA4B-00A0C93EC93B";
      .partitiontable |
      .sectorsize * (.partitions[] | select(.type == ESP_GUID) | .start)
    ')
    mcopy -no -i $pname@@$ESP_OFFSET ${kernel}/dtbs/freescale/imx8qm-mek-hdmi.dtb ::/
    #mcopy -no -i $pname@@$ESP_OFFSET ${config.pkgs.imx-firmware}/hdmitxfw.bin ::/
    mv $pname $out
    runHook postInstall
  '';
})
