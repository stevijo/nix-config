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
    rev = "e34dcb61cdb6d5501237da52cc1fd986ff654ea2";
    hash = "sha256-X273wf6CY8k7KMpSmgbQYjmaURwyYBcpNQYqkRUb/Js=";
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
