# SPDX-License-Identifier: MIT
# SPDX-FileCopyrightText: 2022 Alyssa Ross <hi@alyssa.is><
# SPDX-FileCopyrightText: 2022 Unikie

{ config }:

import ../../spectrum/vm-lib/make-vm.nix { inherit config; } {
    name = "appvm-user";
    run = config.pkgs.callPackage (
      { writeShellScript, chromium }:
      writeShellScript "appvm-chromium-run" ''
        ${chromium}/bin/chromium  --enable-features=UseOzonePlatform --ozone-platform=wayland --no-sandbox
      ''
    ) {};
}
