{ stdenv
, lib
, openssl
, pkg-config
, pcsclite
, fetchFromGitHub
, buildGoModule
}:

buildGoModule rec {
  pname = "age-plugin-yubi25519";
  version = "0.3";

  src = fetchFromGitHub {
    owner = "stevijo";
    repo = "yubikey";
    rev = "33654338b161fa0e8b8661dcc8ea2f5826400e39";
    hash = "sha256-r7YbHOToK7vmT2r5AnUYuyOnTMwAoJDuXac5+q4vUmc=";
  };

  vendorHash = "sha256-t+T9YpCJjrwjwkPlK4nWvtJpTMSx9imlWvD4kSE8pH8=";

  subPackages = [ "extra/age-plugin-yubi25519" ];
  ldflags = [
    "-s"
    "-w"
    "-X main.Version=v${version}"
  ];

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = [
    openssl
  ]
  ++ lib.optionals stdenv.hostPlatform.isLinux [ pcsclite ];

  outputs = [
    "out"
    "dev"
  ];

}
