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
    rev = "be2a0fda19f7270e79a88e4ab9aacce42818c55f";
    hash = "sha256-9yKVDgxS1iYA5/9973drBqPmZRiVY2zBqJ52SOTBeR0=";
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
