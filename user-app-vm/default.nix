# SPDX-License-Identifier: MIT
# SPDX-FileCopyrightText: 2022 Alyssa Ross <hi@alyssa.is><
# SPDX-FileCopyrightText: 2022 Unikie

{ config }:

import ../../spectrum/vm/make-vm.nix { inherit config; } {
    name = "appvm-user";
    run = config.pkgs.pkgsStatic.callPackage (
      { writeShellScript, coreutils }:
      writeShellScript "appvm-yes-run" ''
        ${coreutils}/bin/yes
      ''
    ) {};
}