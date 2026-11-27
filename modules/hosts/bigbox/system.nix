{ ... }:

{
  nixos.configurations.bigbox.module = { lib, pkgs, ... }: {
    system.stateVersion = "26.05";

    networking.hostName = "bigbox";

    environment.systemPackages = with pkgs; [
      git
      vim

      strongswan
    ];

    services.openssh = {
      enable = true;
      settings = {
        PasswordAuthentication = false;
      };
    };

    security.sudo.extraRules = [
      {
        users = [ "stevijo" ];
        commands = [
          {
            command = "ALL";
            options = [ "NOPASSWD" ];
          }
        ];
      }
    ];

    users.users.stevijo = {
      isNormalUser = true;
      group = "wheel";
      extraGroups = [ "network" ];
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPDd4/e0zAwUX8oKNqjvLyWr2kALFTJRcOBE4/gllCwO stevijo@stevijo-laptop"
      ];
    };

    boot.kernel.sysctl = {
      "net.ipv4.fib_multipath_hash_policy" = 1;
      "net.ipv6.fib_multipath_hash_policy" = 1;
      "net.core.netdev_max_backlog" = 10000;
      "net.core.rmem_max" = 16777216;
      "net.core.wmem_max" = 16777216;
      "net.ipv6.conf.all.accept_untracked_na" = 1;
      "net.mptcp.enabled" = 0;
    };

    boot.kernelParams = [
      "isolcpus=2-5"
      "nohz_full=2-5"
      "rcu_nocbs=2-5"
      "nmi_watchdog=0"
      "mitigations=off"
      "intel_idle.max_cstate=0"
      "processor.max_cstate=1"
    ];


    systemd.services.clock-speed = {
      description = "The speed of the clock of the processor";
      wantedBy = [ "network-pre.target" ];

      before = [ "vpp.service" ];
      after = [ "systemd-modules-load.service" ];

      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;

        ExecStart = pkgs.writeShellScript "clock-speed" ''
          # The governor of the cores is the one of the performance.
          for cpu in /sys/devices/system/cpu/cpu[0-9]*; do
            if [ -e "$cpu/cpufreq/scaling_governor" ]; then
              echo performance > "$cpu/cpufreq/scaling_governor"
            fi
          done

          # The cores which are isolated for the workers of the processor of
          # the packets never go under three gigahertz.
          for cpu in 2 3 4 5; do
            if [ -e "/sys/devices/system/cpu/cpu$cpu/cpufreq/scaling_min_freq" ]; then
              echo 3000000 > "/sys/devices/system/cpu/cpu$cpu/cpufreq/scaling_min_freq"
            fi
          done
        '';
      };
    };

    systemd.services.irq-pinning = {
      description = "The interrupts of the network interfaces are kept away from the cores of the processor of the packets";
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" ];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        ExecStart = "${pkgs.writeShellScript "irq-pinning" ''
          # The cores which the kernel isolates are the ones which the
          # processor of the packets uses.
          isolated=$(sed -n "s/.*[^a-z]isolcpus=\([^ ]*\).*/\1/p" /proc/cmdline)
          if [ -z "$isolated" ]; then
            exit 0
          fi

          # The list of the isolated cores.
          cores=""
          for range in $(echo "$isolated" | tr "," " "); do
            case "$range" in
              *-*) cores="$cores $(seq "''${range%-*}" "''${range#*-}" | tr "\n" " ")" ;;
              *) cores="$cores $range" ;;
            esac
          done

          # The mask of the cores which are not isolated.
          cpus=$(grep -c ^processor /proc/cpuinfo)
          mask=0
          for cpu in $(seq 0 $((cpus - 1))); do
            case " $cores " in
              *" $cpu "*) ;;
              *) mask=$((mask | 1 << cpu)) ;;
            esac
          done
          mask=$(printf "%x" $mask)

          # The interfaces of the network are the ones which have a device
          # on the bus of the PCI.
          for interface in /sys/class/net/*; do
            device=$(readlink -f "$interface/device" 2>/dev/null || true)
            if [ -z "$device" ]; then
              continue
            fi

            # The interrupts of a device are the ones of the device of the
            # PCI which holds it, which is the parent of the device of the
            # interface.
            while [ ! -d "$device/msi_irqs" ]; do
              parent=$(dirname "$device")
              if [ "$parent" = "$device" ]; then
                break
              fi
              device=$parent
            done
            if [ ! -d "$device/msi_irqs" ]; then
              continue
            fi

            for irq in "$device"/msi_irqs/*; do
              if [ ! -e "$irq" ]; then
                continue
              fi
              echo "$mask" > "/proc/irq/$(basename "$irq")/smp_affinity" || true
            done
          done
        ''}";
      };
    };

    networking.nameservers = [ "1.1.1.1" ];

    time.timeZone = "Europe/Prague";

    i18n.defaultLocale = "en_US.UTF-8";
  };
}
