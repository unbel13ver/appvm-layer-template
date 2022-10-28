# SPDX-FileCopyrightText: 2022 Unikie

{ config ? import ../../spectrum/nix/eval-config.nix {} }:

let
  inherit (config) pkgs;
  uboot = pkgs.ubootIMX8QM;
  spectrum = import ../../spectrum/release/live { };
  kernel = spectrum.rootfs.kernel;
  appvm-user = pkgs.callPackage ../user-app-vm/default.nix { inherit config; };
  myextpart = with pkgs; runCommand "myext.ext4" {
    nativeBuildInputs = [ e2tools e2fsprogs util-linux p7zip tar2ext4 ];
  } ''
    7z x ${spectrum.EXT_FS}
    cp -r ${appvm-user} svc/data/appvm-user
    tar -cf ext.tar svc
    tar2ext4 -i ext.tar -o $out
  '';
in

with pkgs;

spectrum.overrideDerivation (oldAttrs: {
  EXT_FS = myextpart;
  pname = "temp.img";
  buildCommand = ''
    install -m 0644 ${spectrum} $pname
    dd if=/dev/zero bs=1M count=6 >> $pname
    partnum=$(sfdisk --json $pname | grep "node" | wc -l)
    while [ $partnum -gt 0 ]; do
      echo '+6M,' | sfdisk --move-data $pname -N $partnum
      partnum=$((partnum-1))
    done
    dd if=${uboot}/flash.bin of=$pname bs=1k seek=32 conv=notrunc
    IMG=$pname
    ESP_OFFSET=$(sfdisk --json $IMG | jq -r '
      # Partition type GUID identifying EFI System Partitions
      def ESP_GUID: "C12A7328-F81F-11D2-BA4B-00A0C93EC93B";
      .partitiontable |
      .sectorsize * (.partitions[] | select(.type == ESP_GUID) | .start)
    ')
    mcopy -no -i $pname@@$ESP_OFFSET ${kernel}/dtbs/freescale/imx8qm-mek-hdmi.dtb ::/
    mcopy -no -i $pname@@$ESP_OFFSET ${config.pkgs.imx-firmware}/hdmitxfw.bin ::/
    mv $pname $out
  '';
})
