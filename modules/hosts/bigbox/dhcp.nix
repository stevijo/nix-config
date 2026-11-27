{ ... }:

{
  nixos.configurations.bigbox.module = { config, lib, ... }: {
    services.kea = {
      dhcp4 = {
        enable = true;

        settings = {
          "interfaces-config" = {
            interfaces = [
              "eth1.2"
              "eth1.3"
              "eth1.4"
            ];
            "dhcp-socket-type" = "raw";
          };

          "lease-database" = {
            type = "memfile";
            persist = true;
            name = "/var/lib/kea/dhcp4-leases.csv";
          };

          "shared-networks" = [
            {
              name = "GaesteVlan";
              authoritative = true;
              subnet4 = [
                {
                  subnet = "192.168.10.0/24";
                  id = 1;
                  option-data = [
                    {
                      name = "domain-name-servers";
                      data = "1.1.1.1, 1.0.0.1";
                    }
                    {
                      name = "routers";
                      data = "192.168.10.1";
                    }
                  ];
                  valid-lifetime = 86400;
                  max-valid-lifetime = 86400;
                  pools = [
                    {
                      pool = "192.168.10.2 - 192.168.10.254";
                    }
                  ];
                }
              ];
            }

            {
              name = "NormalVlan";
              authoritative = true;
              subnet4 = [
                {
                  subnet = "192.168.178.0/24";
                  id = 2;
                  option-data = [
                    {
                      name = "domain-name-servers";
                      data = "192.168.178.1";
                    }
                    {
                      name = "domain-name";
                      data = "lan";
                    }
                    {
                      name = "routers";
                      data = "192.168.178.1";
                    }
                  ];
                  valid-lifetime = 86400;
                  max-valid-lifetime = 86400;
                  pools = [
                    {
                      pool = "192.168.178.101 - 192.168.178.101";
                    }
                    {
                      pool = "192.168.178.103 - 192.168.178.108";
                    }
                    {
                      pool = "192.168.178.109 - 192.168.178.163";
                    }
                    {
                      pool = "192.168.178.174 - 192.168.178.174";
                    }
                    {
                      pool = "192.168.178.176 - 192.168.178.200";
                    }
                    {
                      pool = "192.168.178.165 - 192.168.178.172";
                    }
                  ];
                  reservations = [
                    {
                      hostname = "LGTV";
                      hw-address = "38:8C:50:40:D7:4A";
                      ip-address = "192.168.178.100";
                    }
                    {
                      hostname = "ally";
                      hw-address = "14:5a:41:dc:df:b1";
                      ip-address = "192.168.178.164";
                    }
                    {
                      hostname = "bedroom";
                      hw-address = "e4:65:b8:74:ed:2c";
                      ip-address = "192.168.178.173";
                    }
                    {
                      hostname = "livingroom";
                      hw-address = "D4:8A:FC:5F:C4:C8";
                      ip-address = "192.168.178.102";
                    }
                    {
                      hostname = "pikvm";
                      hw-address = "b8:27:eb:01:31:ce";
                      ip-address = "192.168.178.175";
                    }
                    {
                      hostname = "wifi";
                      hw-address = "48:A9:8A:07:E6:61";
                      ip-address = "192.168.178.108";
                    }
                  ];
                }
              ];
            }

            {
              name = "SmartVlan";
              authoritative = true;
              subnet4 = [
                {
                  subnet = "192.168.11.0/24";
                  id = 3;
                  option-data = [
                    {
                      name = "domain-name-servers";
                      data = "1.1.1.1, 1.0.0.1";
                    }
                    {
                      name = "routers";
                      data = "192.168.11.1";
                    }
                  ];
                  valid-lifetime = 86400;
                  max-valid-lifetime = 86400;
                  pools = [
                    {
                      pool = "192.168.11.2 - 192.168.11.254";
                    }
                  ];
                }
              ];
            }
          ];
        };
      };

      dhcp6 = {
        # The server of the addresses of the local networks.
        enable = true;

        settings = {
          "interfaces-config" = {
            interfaces = [ "eth1.2" ];
          };

          "lease-database" = {
            type = "memfile";
            persist = true;
            name = "/var/lib/kea/dhcp6-leases.csv";
          };

          "shared-networks" = [
            {
              name = "NormalVlan";
              option-data = [
                {
                  name = "dns-servers";
                  data = "${config.sops.placeholder."ipv6-eth1-2"}";
                }
              ];
              subnet6 = [
                {
                  subnet = "${config.sops.placeholder."prefix-be00"}";
                  id = 1;
                  interface = "eth1.2";
                  option-data = [
                    {
                      name = "dns-servers";
                      data = "${config.sops.placeholder."ipv6-eth1-2"}";
                    }
                  ];
                }
              ];
            }
          ];
        };
      };
    };
  };
}
