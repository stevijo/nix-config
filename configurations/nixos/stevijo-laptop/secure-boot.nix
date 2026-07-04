# Lanzaboote (Unified Kernel Image + Secure Boot), resume device for
# hibernate, and fstrim for SSD wear leveling. systemd-boot is force-disabled
# so lanzaboote owns the boot entry.
{ lib, ... }:

{
  boot.lanzaboote = {
    enable = true;
    pkiBundle = "/etc/secureboot";
  };
  boot.loader.systemd-boot.enable = lib.mkForce false;
  boot.initrd.systemd.enable = true;
  networking.hostId = "2f6bdf89";
  boot.resumeDevice = "/dev/disk/by-uuid/b30200b1-b70d-4832-979e-be2a51413369";
  services.fstrim.enable = true;
}
