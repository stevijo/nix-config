{ lib, flake, pkgs, ... }:

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
  imports = [
    self.darwinModules.default
  ];

  nixpkgs.hostPlatform = "aarch64-darwin";
  networking.hostName = "G56K599LK7";

  users.users."stefan.mayer".home = "/Users/stefan.mayer";
  home-manager.users."stefan.mayer" =
    {
      imports = [
        (self + "/configurations/home/stefan.mayer@G56K599LK7.nix")
      ];

      java = {
        inherit java17 java21;
      };
    };

  username = "stefan.mayer";

  security.pam.services.sudo_local.touchIdAuth = true;
  security.pki.certificateFiles = [ ./zscaler.pem ];

  system.stateVersion = 6;

  system.primaryUser = "stefan.mayer";
  system.defaults.dock.show-recents = false;
  fonts = {
    packages = with pkgs; [
      nerd-fonts.droid-sans-mono
    ];
  };
  environment = {

    systemPackages = with pkgs; [
      kitty
    ];
    variables = {
      JAVA_HOME_21 = toString java21;
      JAVA_HOME_17 = toString java17;
    };
  };
}
