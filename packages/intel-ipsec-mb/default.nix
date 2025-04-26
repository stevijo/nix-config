{ stdenv
, fetchFromGitHub
, cmake
, nasm
}:

stdenv.mkDerivation rec {
  pname = "intel-ipsec-mb";
  version = "1.4";

  src = fetchFromGitHub {
    owner = "intel";
    repo = "intel-ipsec-mb";
    rev = "v${version}";
    hash = "sha256-wp5hruEBKLu536/m2ep1OjpSQjBUz1Tv5nbmTJodTYc=";
  };

  patches = [
    ./0001-make-install-dir-configurable.patch
  ];

  outputs = [
    "out"
    "dev"
  ];

  nativeBuildInputs = [
    cmake
    nasm
  ];

}
