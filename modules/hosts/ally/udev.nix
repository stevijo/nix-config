{ ... }:

{
  nixos.configurations.ally.module = { lib, pkgs, ... }: {

    services.udev.extraRules = ''
      # manual GPU clock control in Steam
      ACTION=="add", SUBSYSTEM=="pci", DRIVER=="amdgpu", RUN+="${pkgs.coreutils}/bin/chmod a+w /sys/%p/power_dpm_force_performance_level /sys/%p/pp_od_clk_voltage /sys/%p/power_dpm_state"
      SUBSYSTEM=="leds", RUN+="${pkgs.coreutils}/bin/chmod a+w '/sys/class/leds/%k/brightness'"
      SUBSYSTEM=="leds", RUN+="${pkgs.coreutils}/bin/chmod a+w '/sys/class/leds/%k/brightness_scale'"
      SUBSYSTEM=="leds", RUN+="${pkgs.coreutils}/bin/chmod a+w '/sys/class/leds/%k/brightness_startup'"
      SUBSYSTEM=="leds", RUN+="${pkgs.coreutils}/bin/chmod a+w '/sys/class/leds/%k/effect'"
      SUBSYSTEM=="leds", RUN+="${pkgs.coreutils}/bin/chmod a+w '/sys/class/leds/%k/enabled'"
      SUBSYSTEM=="leds", RUN+="${pkgs.coreutils}/bin/chmod a+w '/sys/class/leds/%k/mode'"
      SUBSYSTEM=="leds", RUN+="${pkgs.coreutils}/bin/chmod a+w '/sys/class/leds/%k/multi_intensity'"
      SUBSYSTEM=="leds", RUN+="${pkgs.coreutils}/bin/chmod a+w '/sys/class/leds/%k/multi_intensity_startup'"
      SUBSYSTEM=="leds", RUN+="${pkgs.coreutils}/bin/chmod a+w '/sys/class/leds/%k/speed'"

      # https://github.com/ublue-os/bazzite/blob/f5f033424281f88f0a132ec0561a5a5f002faf24/system_files/deck/shared/usr/lib/udev/rules.d/50-ally-fingerprint.rules
      ACTION=="add", SUBSYSTEM=="usb", TEST=="power/control", ATTR{idVendor}=="1c7a", ATTR{idProduct}=="0588", ATTR{power/control}="auto"
    '';
  };
}
