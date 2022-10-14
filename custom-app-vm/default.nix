# SPDX-License-Identifier: MIT
# SPDX-FileCopyrightText: 2022 Alyssa Ross <hi@alyssa.is>

{ config }:

import ../../spectrum/vm/make-vm.nix { inherit config; } {
    name = "appvm-custom";
    run = config.pkgs.pkgsStatic.callPackage (
      { writeShellScript, coreutils }:
      writeShellScript "appvm-yes-run" ''
        ${coreutils}/bin/yes
      ''
    ) {};
}