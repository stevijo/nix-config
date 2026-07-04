# Java: Temurin JDK 17 + 21 with the Zscaler root CA injected into the
# cacerts keystore. The `java.java17/java21` options are declared by
# `modules/home/all/neovim/default.nix` for the home-manager tree; here
# we wire the home-manager config so that path actually points at the
# Zscaler-patched JDK.
{ flake, pkgs, ... }:

let
  inherit (flake) inputs;
  inherit (inputs) self;
  addZscalerCA = java: java.overrideAttrs (old: {
    installPhase = old.installPhase + ''
      chmod 644 $out/lib/security/cacerts
      echo changeit | $out/bin/keytool -noprompt -import -alias zscaler -file ${./zscaler.pem} -keystore $out/lib/security/cacerts
      chmod 444 $out/lib/security/cacerts
    '';
  });
  java21 = addZscalerCA pkgs.temurin-bin;
  java17 = addZscalerCA pkgs.temurin-bin-17;
in
{
  home-manager.users."stefan.mayer".java = {
    inherit java17 java21;
  };

  environment.variables = {
    JAVA_HOME_21 = toString java21;
    JAVA_HOME_17 = toString java17;
  };
}
