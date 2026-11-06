# Kernel and Valve kernel patches for the ROG Xbox Ally X20.
#
# The patches in ./kernel are backports from Valve's linux-integration
# 7.2.10-valve1, which the pinned 7.2.7-valve2 does not have.
{ pkgs, ... }:

{
  boot.kernelPackages = pkgs.jovianPackages.linuxPackages;

  boot.kernelPatches = [
    {
      name = "0001-ASoC-amd-acpi-add-RC74XA-link0-tas2783-layout";
      patch = ./kernel/0001-ASoC-amd-acpi-add-RC74XA-link0-tas2783-layout.patch;
    }
    {
      name = "0002-ACPI-x86-quirk-ignore-acp-audio-config-flag-RC74XA";
      patch = ./kernel/0002-ACPI-x86-quirk-ignore-acp-audio-config-flag-RC74XA.patch;
    }
    {
      name = "0003-ASoC-sdw_utils-honor-empty-DisCo-port-lists";
      patch = ./kernel/0003-ASoC-sdw_utils-honor-empty-DisCo-port-lists.patch;
    }
    {
      name = "0004-ASoC-tas2783-sdw-keep-the-volume-settings-across-resets";
      patch = ./kernel/0004-ASoC-tas2783-sdw-keep-the-volume-settings-across-resets.patch;
    }
    {
      name = "0005-ASoC-tas2783-sdw-load-the-firmware-synchronously";
      patch = ./kernel/0005-ASoC-tas2783-sdw-load-the-firmware-synchronously.patch;
    }
    {
      name = "0006-ASoC-tas2783-sdw-refuse-playback-when-init-writes-failed";
      patch = ./kernel/0006-ASoC-tas2783-sdw-refuse-playback-when-init-writes-failed.patch;
    }
    {
      name = "0007-ASoC-tas2783-sdw-power-the-function-up-before-preparing-the-port";
      patch = ./kernel/0007-ASoC-tas2783-sdw-power-the-function-up-before-preparing-the-port.patch;
    }
    {
      name = "0010-hid-asus-ally-alias-LED-to-go_s-and-fix-mc_subled";
      patch = ./kernel/0010-hid-asus-ally-alias-LED-to-go_s-and-fix-mc_subled.patch;
    }
    {
      name = "0011-hid-asus-ally-add-effect-speed-mode-sysfs";
      patch = ./kernel/0011-hid-asus-ally-add-effect-speed-mode-sysfs.patch;
    }
    {
      name = "0013-hid-asus-ally-fix-use-after-free-on-interface-unbind";
      patch = ./kernel/0013-hid-asus-ally-fix-use-after-free-on-interface-unbind.patch;
    }
    {
      name = "0014-hid-asus-ally-scale-rumble-and-vibration-intensity-to-0-100";
      patch = ./kernel/0014-hid-asus-ally-scale-rumble-and-vibration-intensity-to-0-100.patch;
    }
    {
      name = "0016-HID-asus-ally-remap-QAM-and-AC-buttons-on-ROG-Xbox-Ally-X20";
      patch = ./kernel/0016-HID-asus-ally-remap-QAM-and-AC-buttons-on-ROG-Xbox-Ally-X20.patch;
    }
    {
      name = "0017-HID-asus-ally-reconfigure-the-MCU-only-once-on-resume";
      patch = ./kernel/0017-HID-asus-ally-reconfigure-the-MCU-only-once-on-resume.patch;
    }
    {
      name = "0018-HID-asus-ally-restore-the-gamepad-mode-on-resume";
      patch = ./kernel/0018-HID-asus-ally-restore-the-gamepad-mode-on-resume.patch;
    }
    {
      name = "0019-HID-asus-ally-propagate-ready-check-transport-errors";
      patch = ./kernel/0019-HID-asus-ally-propagate-ready-check-transport-errors.patch;
    }
    {
      name = "0020-asus-armoury-add-ROG-Xbox-Ally-X20-RC74XA-power-limits";
      patch = ./kernel/0020-asus-armoury-add-ROG-Xbox-Ally-X20-RC74XA-power-limits.patch;
    }
  ];

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
  '';

  boot.consoleLogLevel = 0;
}
