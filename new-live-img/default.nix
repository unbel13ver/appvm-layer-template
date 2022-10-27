# SPDX-FileCopyrightText: 2022 Unikie

{ config ? import ../../spectrum/nix/eval-config.nix {} }:

let
  inherit (config) pkgs;
  spectrum = import ../../spectrum/release/live { };
  kernel = spectrum.rootfs.kernel;
  appvm-user = pkgs.callPackage ../user-app-vm/default.nix { inherit config; };
  myextpart = with pkgs; runCommand "myext.ext4" {
    nativeBuildInputs = [ e2tools e2fsprogs util-linux p7zip tar2ext4 ];
  } ''
    7z x ${spectrum.EXT_FS}
    cp -r ${appvm-user}/data svc/
    tar -cf ext.tar svc
    tar2ext4 -i ext.tar -o $out
  '';
in

with pkgs;

spectrum.overrideDerivation (oldAttrs: {
  EXT_FS = myextpart;
})
