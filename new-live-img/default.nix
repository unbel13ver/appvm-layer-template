# SPDX-FileCopyrightText: 2022 Unikie

{ config ? import ../../spectrum/nix/eval-config.nix {} }:

let
  inherit (config) pkgs;
  spectrum = import ../../spectrum/release/live { };
  kernel = spectrum.rootfs.kernel;
  customer-vms = pkgs.callPackage ./custom-vms.nix { inherit config; };
in

with pkgs;

stdenvNoCC.mkDerivation {
  pname = "new-spectrum-live.img";
  version = "0.2";

  unpackPhase = "true";

  nativeBuildInputs = [
    pkgsBuildHost.util-linux
    pkgsBuildHost.jq
    pkgsBuildHost.mtools
  ];

  buildCommand = ''
    install -m 0644 ${spectrum} $pname
    # Append ~0.5 Gb of space to the image 
    dd if=/dev/zero bs=1M count=500 >> $pname
    dd if=${customer-vms} of=$pname seek=$(expr $(fdisk -l $pname | tail -n 1 |  awk '{print $3}') + 1) conv=notrunc
    echo "n



    w" | fdisk $pname
    cp $pname $out
  '';
}
