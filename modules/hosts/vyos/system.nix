# The system level settings of the faster-router: the name, the accounts,
# the packages and the kernel settings of the VyOS configuration.
{ config, lib, pkgs, ... }:

{
  nixos.configurations.vyos.module = { lib, pkgs, ... }: {
    system.stateVersion = "26.05";

    networking.hostName = "vyos";

    environment.systemPackages = with pkgs; [
      git
      vim

      # The command of the tunnel of IPsec. The module of the resolver of
      # the kernel puts the package in the path of the service alone, so
      # the command is not there for the shell.
      strongswan
    ];

    services.openssh = {
      enable = true;
      settings = {
        PasswordAuthentication = false;
        Port = 2222;
      };
    };

    # The user account. The key is the one of the age key, which the router
    # needs anyway to decrypt its secrets, so that the account is the way
    # into the router when the network is down.
    users.users.stevijo = {
      isNormalUser = true;
      group = "wheel";
      extraGroups = [ "network" ];
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPDd4/e0zAwUX8oKNqjvLyWr2kALFTJRcOBE4/gllCwO stevijo@stevijo-laptop"
      ];
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

    # The console of the machine. It is the only way in when the network is
    # down: the serial port of the machine (ttyS0), which is the serial port
    # of a virtual machine and of a server, and the serial port of the
    # management controller (ttyUSB0), which is reached with IPMI.

    # The gettys of the serial ports, so that the machine can be logged in
    # when the network is down.
    systemd.services."serial-getty@ttyS0" = {
      enable = true;
      unitConfig.ConditionPathExists = "/dev/ttyS0";
    };

    systemd.services."serial-getty@ttyUSB0" = {
      enable = true;
      unitConfig.ConditionPathExists = "/dev/ttyUSB0";
    };

    # The sysctl settings of the VyOS configuration.
    boot.kernel.sysctl = {
      "net.core.netdev_max_backlog" = 10000;
      "net.core.rmem_max" = 16777216;
      "net.core.wmem_max" = 16777216;
      "net.mptcp.enabled" = 0;

      # The sockets of the default instance do not see the packets which
      # arrive on the connections of the instances: the administration of the
      # router and the resolver of the machine are in the default instance,
      # and the connections to the provider are in the first one. The kernel
      # has to accept them, like it does on the router which is in service.
      "net.ipv4.tcp_l3mdev_accept" = 1;
      "net.ipv4.udp_l3mdev_accept" = 1;
    };

    # The CPU settings of the VyOS configuration: the cores 2 to 7 are
    # reserved for the workers of VPP, and the mitigations of the kernel are
    # disabled.
    boot.kernelParams = [
      "isolcpus=2-7"
      "nohz_full=2-7"
      "rcu_nocbs=2-7"
      "nmi_watchdog=0"
      "mitigations=off"
      "intel_iommu=on"
      "console=ttyUSB0,115200n8"
      "console=ttyS0,115200n8"
    ];

    # The name server of the VyOS configuration.
    networking.nameservers = [ "1.1.1.1" ];

    # The store of the machine is filled from the laptop, which builds the
    # paths of the configuration itself and does not sign them. The cache of
    # the cache.nixos.org is signed and is the only other source of the
    # paths of the machine.
    #
    # This is the only setting of nix which this configuration changes, and
    # it changes it while the machine is the one of the lab. The router
    # which is in service keeps the signatures, and its paths are signed by
    # the key of the machine itself.
    nix.settings.require-sigs = lib.mkForce false;

    time.timeZone = "Europe/Prague";

    i18n.defaultLocale = "en_US.UTF-8";

    # The time servers of the VyOS configuration.
    services.ntp = {
      enable = true;
      servers = [
        "time1.vyos.net"
        "time2.vyos.net"
        "time3.vyos.net"
      ];

      # The daemon opens a socket on every connection of the machine, and it
      # crashes when it fails to open one, which it does on the connections
      # which are in a virtual routing instance: the address of the instance
      # is not reachable outside of it. It listens on the connection to the
      # office alone.
      extraFlags = [ "--interface=eth0" ];

      # The clients which are allowed to ask the machine for the time, which
      # are the ones of the VyOS configuration. The option of the module takes
      # the flags of the restriction and not the addresses, so the addresses
      # are written here, one line each.
      extraConfig = ''
        restrict source 127.0.0.0/8 limited kod notrap
        restrict source 169.254.0.0/16 limited kod notrap
        restrict source 10.0.0.0/8 limited kod notrap
        restrict source 172.16.0.0/12 limited kod notrap
        restrict source 192.168.0.0/16 limited kod notrap
        restrict -6 source ::1/128 limited kod notrap
        restrict -6 source fe80::/10 limited kod notrap
        restrict -6 source fc00::/7 limited kod notrap
      '';
    };

    # The trim of the disk of the VyOS configuration. The unit of the
    # systemd package does the work, and the timer of the configuration
    # runs it every day.
    services.fstrim.enable = true;

    systemd.timers.fstrim = {
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnCalendar = "*-*-* 00:00:00";
        RandomizedDelaySec = "12h";
        Persistent = true;
      };
    };
  };
}
