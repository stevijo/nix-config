{ ... }:

{
  flake.modules.darwin."darwinConfigurations/G56K599LK7" = { ... }: {

    security.pki.certificateFiles = [ ./zscaler.pem ];
  };
}
