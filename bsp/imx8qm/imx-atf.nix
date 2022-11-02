{
  buildArmTrustedFirmware ,
}:

{
  armTrustedFirmwareiMX8QM = buildArmTrustedFirmware rec {
    src = fetchGit {
      url = "https://source.codeaurora.org/external/imx/imx-atf";
      ref = "lf_v2.6";
    };
    platform = "imx8qm";
    enableParallelBuilding = true;
    # To build with tee.bin use extraMakeFlags = [ "bl31 SPD=opteed" ];
    extraMakeFlags = [ "bl31" ];
    extraMeta.platforms = ["aarch64-linux"];
    filesToInstall = ["build/${platform}/release/bl31.bin"];
  };
}
