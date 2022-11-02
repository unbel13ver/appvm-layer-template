{ pkgs }:

with pkgs;
pkgs.stdenv.mkDerivation rec {
  pname = "imx-mkimage";
  version = "lf-5.15.32-2.0.0";

  src = fetchgit {
    url = "https://source.codeaurora.org/external/imx/imx-mkimage.git";
    rev = version;
    sha256 = "sha256-9buTYj0NdKV9CpzHfj7sIB5sRzS4Md48pn2joy+T97U=";
    leaveDotGit = true;
  };

  nativeBuildInputs = [
    git
  ];

  buildInputs = [
    git
    glibc.static
  ];

  makeFlags = [
    "bin"
  ];

  installPhase = ''
    install -m 0755 mkimage_imx8 $out
  '';
}
