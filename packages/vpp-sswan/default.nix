{ stdenv
, fetchFromGitHub
, systemd
, vpp
, strongswan
}:
let
  strongswan' = strongswan.overrideAttrs (old: {
    pname = "${old.pname}-configured";
    phases = [
      "unpackPhase"
      "patchPhase"
      "autoreconfPhase"
      "configurePhase"
      "installPhase"
    ];
    installPhase = "cp -pr --reflink=auto -- . $out";
  });
in
stdenv.mkDerivation {
  pname = "vpp-sswan";
  version = vpp.version;

  src = vpp.src;
  patches = [
    ./0001-strongswan-add-bypass-rule-for-ipv6-and-add-policy-t.patch
    ./0002-strongswan-enable-sa-update.patch
  ];

  buildInputs = [ vpp systemd.dev ];
  nativeBuildInputs = [ strongswan' ];

  dontPatchELF = true;

  postPatch = ''
    sed -i 's/cp.*//' Makefile
  '';

  env.NIX_CFLAGS_COMPILE = "-Wno-error=incompatible-pointer-types";

  makeFlags = [
    "SWANDIR=${strongswan'}"
    "libstrongswan-kernel-vpp.so"
  ];

  sourceRoot = "source/extras/strongswan/vpp_sswan";
  installPhase = ''
    mkdir -p $out/lib/ipsec/plugins $out/etc/strongswan.d/charon
    cp ./libstrongswan-kernel-vpp.so $out/lib/ipsec/plugins
    cp ./kernel-vpp.conf $out/etc/strongswan.d/charon
  '';
}
