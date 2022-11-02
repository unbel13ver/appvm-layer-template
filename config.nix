{
  pkgs = import <nixpkgs> {
    overlays = [
      (self: super:
        {
          linux_imx8 = super.linux_imx8.override {
            structuredExtraConfig = with self.lib.kernel; {
              EFI_STUB = yes;
              EFI = yes;
              VIRTIO = yes;
              VIRTIO_PCI = yes;
              VIRTIO_BLK = yes;
              DRM_VIRTIO_GPU = yes;
              EXT4_FS = yes;
              USBIP_CORE = module ;
              USBIP_VHCI_HCD = module;
              USBIP_HOST = module;
              USBIP_VUDC = module;
            };
          };
          makeModulesClosure = args: super.makeModulesClosure (args // {
            rootModules = [ "dm-verity" "loop" ];
          });
        })
    ];
  };
}
