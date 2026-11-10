{ ... }:

{
  nixDarwin.configurations.G56K599LK7.module = { ... }: {

    security.pki.certificateFiles = [ ./zscaler.pem ];
  };
}
