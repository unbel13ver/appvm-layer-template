
self: super: {

  crosvm = self.callPackage ./crosvm.nix { inherit (super) crosvm; };  

}
