# Java: Temurin JDK 17 + 21 with the Zscaler root CA injected into the
# cacerts keystore. The `java.java17/java21` options are declared by the
# neovim home-manager feature; here we wire the home-manager config so that
# path actually points at the Zscaler-patched JDK.
{ ... }:

let
  addZscalerCA = java: java.overrideAttrs (old: {
    installPhase = old.installPhase + ''
      chmod 644 $out/lib/security/cacerts
      echo changeit | $out/bin/keytool -noprompt -import -alias zscaler -file ${./zscaler.pem} -keystore $out/lib/security/cacerts
      chmod 444 $out/lib/security/cacerts
    '';
  });
in
{
  nixDarwin.configurations.G56K599LK7.module = { pkgs, ... }: {
    environment.variables = {
      JAVA_HOME_21 = toString (addZscalerCA pkgs.temurin-bin);
      JAVA_HOME_17 = toString (addZscalerCA pkgs.temurin-bin-17);
    };
  };

  homeManager.modules."stefan.mayer" = { pkgs, ... }: {
    java = {
      java21 = addZscalerCA pkgs.temurin-bin;
      java17 = addZscalerCA pkgs.temurin-bin-17;
    };
  };
}
