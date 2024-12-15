{ vpp
, fetchFromGitHub
}:
vpp.overrideAttrs rec {
  version = "24.10";
  src = fetchFromGitHub {
    owner = "FDio";
    repo = "vpp";
    rev = "v${version}";
    hash = "sha256-GcmblIAu/BDbqZRycmnBsHkvzJe07qB2lSfDnO7ZYtg=";
  };
  patches = [
    ./0001-ipsec-fix-UDP-flow-in-ipsec-inbound-policy.patch
  ];
  preConfigure = ''
    echo "${version}-nixos" > scripts/.version
    scripts/version
  '';
}
