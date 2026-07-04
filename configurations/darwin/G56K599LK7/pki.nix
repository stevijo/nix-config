# Trust anchors: Zscaler root CA so HTTPS interception works for corp traffic.
{ ... }:

{
  security.pki.certificateFiles = [ ./zscaler.pem ];
}
