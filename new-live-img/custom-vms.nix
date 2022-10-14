# SPDX-FileCopyrightText: 2022 Unikie

{ config, runCommand, tar2ext4 }:

let
  appvm-custom = import ../custom-app-vm/default.nix { inherit config; };
in
runCommand "customer-vms.ext4" {
  nativeBuildInputs = [ tar2ext4 ];
} ''
  mkdir -p svc/data/appvm-custom

  chmod +w svc/data

  tar -C ${appvm-custom} -c . | tar -C svc/data/appvm-custom -x

  tar -cf customer-vms.tar svc
  tar2ext4 -i customer-vms.tar -o $out
''
