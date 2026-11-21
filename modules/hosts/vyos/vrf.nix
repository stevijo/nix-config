# The virtual routing instances of the faster-router.
#
# The instances are made by the network of systemd, which puts the
# connections in them. They have to be described as devices of the network
# of systemd, or it does not find them and it leaves the connections out of
# them (`conn1 NetDev could not be found, ignoring assignment`).
#
# The addresses of the connections are set by the network of systemd as well,
# after it has put the connections in the instances: the kernel does not move
# the addresses of an interface which is put into an instance afterwards, so
# the order matters.
{ config, lib, pkgs, ... }:

{
  nixos.configurations.vyos.module = { lib, pkgs, ... }: {
    systemd.network.netdevs = {
      # The first instance, which is the table 100, holds the connection to
      # the provider which is the first one, like the first connection of the
      # routers is in the first instance.
      "10-conn1" = {
        netdevConfig = {
          Name = "conn1";
          Kind = "vrf";
        };
        vrfConfig.Table = 100;
      };

      # The second instance, which is the table 101, is the one of the second
      # connection of the routers, which is the one to the provider as well.
      "10-conn2" = {
        netdevConfig = {
          Name = "conn2";
          Kind = "vrf";
        };
        vrfConfig.Table = 101;
      };
    };

    # The instances need a file of the network of systemd of their own: the
    # network of systemd leaves a device which it does not manage down, and
    # the traffic of a connection of an instance only goes through the
    # instance when it is up.
    #
    # The files name the instances, so that the network of systemd manages
    # them: a file without a name is ignored, and the instance stays down.
    systemd.network.networks = {
      "10-conn1" = {
        matchConfig.Name = "conn1";
      };
      "10-conn2" = {
        matchConfig.Name = "conn2";
      };
    };
  };
}
