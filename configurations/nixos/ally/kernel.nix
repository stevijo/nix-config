# Kernel for the ROG Xbox Ally X20.
#
{ pkgs, ... }:

{
  boot.kernelPackages = pkgs.jovianPackages.linuxPackages;
  boot.kernelModules = [
    "hid_nintendo"
    "hid_playstation"
    "iio_trig_hrtimer"
  ];

  boot.kernelParams = [
    "quiet"
    "splash"
    "amd_pstate=active"
    "rd.systemd.show_status=false"
    "amdgpu.gttsize=8128"
    "rd.udev.log_level=3"
    "rd.systemd.show_status=auto"
  ];

  boot.extraModprobeConfig = ''
    options mt7921e disable_aspm=1
    options mt7921_common disable_clc=1
  '';

  boot.consoleLogLevel = 0;
}
