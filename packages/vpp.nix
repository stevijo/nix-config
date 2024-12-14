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
}
