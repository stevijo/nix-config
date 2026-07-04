# Fingerprint reader + polkit rule to allow verify without password prompt.
{ pkgs, ... }:

{
  services.pcscd.enable = true;
  services.fprintd.enable = true;
  security.polkit.extraConfig = ''
    polkit.addRule(function(action, subject) {
      if (action.id == "net.reactivated.fprint.device.verify") {
        return polkit.Result.YES;
      }
    });
  '';
  services.dbus.packages = [ pkgs.gcr ];
  services.udev.packages = [ pkgs.yubikey-personalization ];
}
