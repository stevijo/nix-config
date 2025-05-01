{ stdenv
, fetchFromGitHub
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

  outputs = [
    "out"
    "dev"
  ];

  makeFlags = [
    "PREFIX=$(out)"
    "SHARED=${if stdenv.hostPlatform.isStatic then "n" else "y"}"
    "NOLDCONFIG=y"
  ];

  nativeBuildInputs = [
    nasm
  ];


}
