# Kernel for the ROG Xbox Ally X20.
#
# The kernel is Valve's linux-integration 7.2.10-valve1 (via Jovian), which
# has the X20 button remap, the rumble scaling and the resume fixes. The
# patches below add the joystick ring LED work, which is not upstream.
{ pkgs, ... }:

{
  boot.kernelPackages = pkgs.jovianPackages.linuxPackages;

  boot.kernelPatches = [
    {
      name = "0010-hid-asus-ally-alias-LED-to-go_s-and-fix-mc_subled";
      patch = ./kernel/0010-hid-asus-ally-alias-LED-to-go_s-and-fix-mc_subled.patch;
    }
    {
      name = "0011-hid-asus-ally-add-effect-speed-mode-sysfs";
      patch = ./kernel/0011-hid-asus-ally-add-effect-speed-mode-sysfs.patch;
    }
  ];
  boot.kernel.sysctl = {
    "kernel.sysrq" = 1;
    "kernel.split_lock_mitigate" = 0;
    "kernel.nmi_watchdog" = 0;
    "kernel.sched_bore" = "1";
  };

  nixpkgs.overlays = [
    (self: super: {
      # The kernel asks for the TAS2783 amplifier firmware as
      # "<subsystem>-<link>-0x<uid>.bin", but linux-firmware only ships the
      # four field variant. The files also have to be listed in WHENCE, which
      # is what copy-firmware.sh installs from.
      linux-firmware = self.callPackage
        ({ fetchFromGitLab, linux-firmware' }: linux-firmware'.overrideAttrs (oldAttrs: {
          version = "20261019-new";

          src = fetchFromGitLab {
            owner = "kernel-firmware";
            repo = "linux-firmware";
            rev = "6d6bffb1d85a1fe077f26853edce482f6c112f2b";
            hash = "sha256-B2i7ztmhjsub5pTuBU/E2oXJZ8u3dqwKQZGu+0KwjZE=";
          };
          postPatch = ''
            cp ti/audio/tas2783/1954-0-0-0x8.bin ti/audio/tas2783/1954-0-0x8.bin
            cp ti/audio/tas2783/1954-0-0-0xB.bin ti/audio/tas2783/1954-0-0xB.bin

            printf '%s\n' \
              'File: ti/audio/tas2783/1954-0-0x8.bin' \
              'File: ti/audio/tas2783/1954-0-0xB.bin' \
              'Link: 1954-0-0x8.bin -> ti/audio/tas2783/1954-0-0x8.bin' \
              'Link: 1954-0-0xB.bin -> ti/audio/tas2783/1954-0-0xB.bin' \
              >> WHENCE
          '';
        }))
        {
          linux-firmware' = super.linux-firmware;
        };
    }

    )
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
    options mt7921_common disable_clc=1
  '';

  boot.consoleLogLevel = 0;
}
