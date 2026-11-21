# The firewall: the nftables rulesets of the routers.
#
# The module renders a rule set into nftables: the groups become sets, the
# rule sets become the chains of the filter, nat and mangle tables, and the
# policy routing becomes the marks of the mangle table.
#
# It is imported by the hosts which run a firewall of their own:
#
#   imports = [ firewall ];
#
#   firewall.groups.interface.wireguard = [ "wg0" "eth2.6" "vppgre0" ];
#   firewall.rules.filter.ipv4.input = {
#     defaultAction = "drop";
#     rules = [
#       {
#         action = "accept";
#         comment = "Allow established";
#         state = [ "established" "related" ];
#       }
#     ];
#   };
#
# The rules of the two address families are kept apart, because the rules of
# one family do not apply to the other: an address group of the IPv4 rules
# has no counterpart in the IPv6 rules.
{ config, lib, ... }:

{
  nixos.modules.firewall = { config, lib, ... }:
    let
      cfg = config.firewall;

      # A group of names: the interfaces, addresses, networks or mac
      # addresses of a set.
      groupType = lib.types.attrsOf (lib.types.listOf lib.types.str);

      # The values of a match: one value, or a list of them.
      valuesType = lib.types.either lib.types.str (lib.types.listOf lib.types.str);

      # One rule of a chain.
      ruleType = lib.types.submodule {
        options = {
          action = lib.mkOption {
            type = lib.types.str;
            default = "";
            description = ''
              The action of the rule, inserted as it is into the ruleset.
              For example `accept`, `drop`, `masquerade`, `dnat to
              192.168.178.1` or `meta mark set 0x7fffff9a accept`.
            '';
          };

          comment = lib.mkOption {
            type = lib.types.str;
            default = "";
            description = "The comment of the rule.";
          };

          counter = lib.mkOption {
            type = lib.types.bool;
            default = true;
            description = "Whether the rule counts the packets it matches.";
          };

          inbound = lib.mkOption {
            type = valuesType;
            default = [ ];
            description = ''
              The interfaces the packet comes in on. The name of an interface
              group is matched as the group, every other name as the
              interface itself.
            '';
          };

          outbound = lib.mkOption {
            type = valuesType;
            default = [ ];
            description = "The interfaces the packet goes out on.";
          };

          protocol = lib.mkOption {
            type = valuesType;
            default = [ ];
            description = "The protocol of the packet, for example `tcp` or `udp`.";
          };

          destinationPort = lib.mkOption {
            type = valuesType;
            default = [ ];
            description = "The port the packet goes to.";
          };

          source = lib.mkOption {
            type = valuesType;
            default = [ ];
            description = ''
              The address the packet comes from. The name of an address, a
              network or a mac address group is matched as the group, every
              other value as the address itself. A value which begins with
              `!` is not matched.
            '';
          };

          destination = lib.mkOption {
            type = valuesType;
            default = [ ];
            description = "The address the packet goes to.";
          };

          state = lib.mkOption {
            type = valuesType;
            default = [ ];
            description = "The states of the connection, for example `established`.";
          };

          icmpv6Type = lib.mkOption {
            type = valuesType;
            default = [ ];
            description = ''
              The type of the ICMPv6 message, for example `echo-request` or
              `nd-router-solicit`.
            '';
          };

          mark = lib.mkOption {
            type = lib.types.nullOr lib.types.int;
            default = null;
            description = "The mark of the packet.";
          };

          ctMark = lib.mkOption {
            type = lib.types.nullOr lib.types.int;
            default = null;
            description = "The mark of the connection.";
          };

          raw = lib.mkOption {
            type = lib.types.nullOr lib.types.lines;
            default = null;
            description = ''
              The match of the rule, as it is inserted into the ruleset. It
              replaces the matches of the other options of the rule.
            '';
          };
        };
      };

      # One chain of a table.
      chainType = lib.types.submodule {
        options = {
          defaultAction = lib.mkOption {
            type = lib.types.nullOr lib.types.str;
            default = null;
            description = ''
              The action of the last rule of the chain, the one which is
              reached when no other rule matches.
            '';
          };

          policy = lib.mkOption {
            type = lib.types.str;
            default = "accept";
            description = "The policy of the chain.";
          };

          priority = lib.mkOption {
            type = lib.types.nullOr lib.types.str;
            default = null;
            description = ''
              The priority of the chain, which decides in which order the
              chains of the hooks are run. It defaults to the priority of the
              table of the chain.
            '';
          };

          rules = lib.mkOption {
            type = lib.types.listOf ruleType;
            default = [ ];
            description = "The rules of the chain, in the order they are tried.";
          };
        };
      };

      # The chains of a table, keyed by the name of the chain.
      chainsType = lib.types.attrsOf chainType;

      # The chains of a table, for the two address families.
      familyType = lib.types.submodule {
        options = {
          ipv4 = lib.mkOption {
            type = chainsType;
            default = { };
            description = "The chains of the IPv4 rules.";
          };
          ipv6 = lib.mkOption {
            type = chainsType;
            default = { };
            description = "The chains of the IPv6 rules.";
          };
        };
      };

      # The hooks of nftables. A chain which is named after one of them is
      # a hook of the table, every other chain is a helper chain.
      hooks = [
        "input"
        "forward"
        "output"
        "prerouting"
        "postrouting"
      ];

      # The protocols which nftables matches by their own name.
      transports = [
        "tcp"
        "udp"
        "icmp"
        "icmpv6"
        "esp"
        "ah"
        "sctp"
        "gre"
      ];

      # The kind of a group a name belongs to, or null if it is not a group.
      groupKind =
        name:
        if lib.hasAttr name cfg.groups.interface then
          "interface"
        else if lib.hasAttr name cfg.groups.address then
          "address"
        else if lib.hasAttr name cfg.groups.network then
          "network"
        else if lib.hasAttr name cfg.groups.mac then
          "mac"
        else
          null;

      # The name of the set of a group, in the family of the table.
      setName =
        family: kind: name:
        {
          interface = "I_${name}";
          address = (if family == "ip6" then "A6_" else "A_") + name;
          network = (if family == "ip6" then "N6_" else "N_") + name;
          mac = "M_${name}";
        }.${kind};

      # A value or a list of values, as nftables writes them.
      set =
        values:
        let
          items = lib.toList values;
        in
        if items == [ ] then
          ""
        else if builtins.length items == 1 then
          builtins.head items
        else
          "{ ${lib.concatStringsSep ", " items} }";

      # The sets of the groups, in the family of the table.
      renderSets =
        family:
        let
          # The type of a set, and the way its elements are written.
          #
          # The sets of the interfaces and of the mac addresses are written
          # even when they are empty, because the rules refer to them. The
          # sets of the addresses and of the networks are only written when
          # they have values of the family of the table.
          types = {
            interface = {
              type = "ifname";
              flags = true;
              quote = true;
              always = true;
            };
            address = {
              type = if family == "ip6" then "ipv6_addr" else "ipv4_addr";
              flags = true;
              quote = false;
              always = false;
            };
            network = {
              type = if family == "ip6" then "ipv6_addr" else "ipv4_addr";
              flags = true;
              quote = false;
              always = false;
            };
            mac = {
              type = "ether_addr";
              flags = false;
              quote = false;
              always = true;
            };
          };

          # The family of a value and the value itself. The family of an
          # address is told by its text, but the placeholder of a secret
          # holds the addresses of the family only, so a value can name
          # its family with the `ip4:` or the `ip6:` prefix.
          valueFamily =
            value:
            if lib.hasPrefix "ip4:" value then {
              family = "ip";
              value = lib.removePrefix "ip4:" value;
            } else if lib.hasPrefix "ip6:" value then {
              family = "ip6";
              value = lib.removePrefix "ip6:" value;
            } else if lib.hasInfix ":" value then {
              family = "ip6";
              value = value;
            } else {
              family = "ip";
              value = value;
            };

          # The values of a group which belong to the family of the table.
          valuesOf =
            kind: name:
            let
              values = cfg.groups.${kind}.${name};
            in
            if kind == "interface" then
              values
            else if kind == "mac" then
              lib.map (value: lib.toLower value) values
            else
              lib.filter (value: (valueFamily value).family == family) values;

          sets = lib.concatMap
            (kind:
              lib.mapAttrsToList
                (name: _:
                  let
                    values = valuesOf kind name;
                    element =
                      value:
                      let
                        text = (valueFamily value).value;
                      in
                      if types.${kind}.quote then "\"${text}\"" else text;
                    body = [
                      "type ${types.${kind}.type}"
                    ]
                    ++ (if types.${kind}.flags then [
                      "flags interval"
                      "auto-merge"
                    ] else [ ])
                    ++ (if values == [ ] then [ ] else [
                      "elements = { ${lib.concatStringsSep ", " (lib.map element values)} }"
                    ]);
                  in
                  lib.optionalString (values != [ ] || types.${kind}.always) ''
                    set ${setName family kind name} {
                      ${lib.concatStringsSep "\n" (lib.map (line: "  ${line}") body)}
                    }
                  '')
                cfg.groups.${kind})
            [
              "interface"
              "address"
              "network"
              "mac"
            ];
        in
        lib.concatStringsSep "\n" sets;

      # The interfaces of a match, as the expressions of the ruleset.
      renderInterfaces =
        keyword: values:
        let
          items = lib.toList values;
          groups = lib.filter (value: groupKind value == "interface") items;
          names = lib.filter (value: groupKind value != "interface") items;
          quote = value: "\"${value}\"";
        in
        lib.concatStringsSep " " (
          lib.filter (expression: expression != null) [
            (if names != [ ] then
              "${keyword} ${
                if builtins.length names == 1 then
                  quote (builtins.head names)
                else
                  "{ ${lib.concatStringsSep ", " (lib.map quote names)} }"
              }"
            else
              null)
            (if groups != [ ] then
              lib.concatStringsSep " "
                (
                  lib.map (group: "${keyword} @${setName "ip" "interface" group}") groups
                )
            else
              null)
          ]
        );

      # The addresses of a match, as the expressions of the ruleset.
      renderAddresses =
        family: keyword: values:
        let
          items = lib.toList values;
          render =
            value:
            let
              # A value is negated when it begins with a single exclamation
              # mark. The placeholders of the secrets begin with two of them.
              negated = lib.hasPrefix "!" value && !(lib.hasPrefix "!!" value);
              name = if negated then lib.removePrefix "!" value else value;
              kind = groupKind name;
              # A mac address is written in lower case, like nftables does.
              mac = builtins.match "([0-9A-Fa-f]{2}:){5}[0-9A-Fa-f]{2}" name != null;
              address = if mac then lib.toLower name else name;
            in
            if kind == null then
              (if mac then
                (if negated then "ether saddr != ${address}" else "ether saddr ${address}")
              else
                (if negated then "${keyword} != ${address}" else "${keyword} ${address}"))
            else if kind == "mac" then
              (if negated then
                "ether saddr != @${setName family kind name}"
              else
                "ether saddr @${setName family kind name}")
            else
              (if negated then
                "${keyword} != @${setName family kind name}"
              else
                "${keyword} @${setName family kind name}");
        in
        lib.concatStringsSep " " (lib.map render items);

      # The protocol and the port of a match, as the expressions of the
      # ruleset.
      renderTransport =
        protocol: destinationPort:
        let
          protocols = lib.toList protocol;
          ports = lib.toList destinationPort;
          single = builtins.length protocols == 1 && lib.elem (builtins.head protocols) transports;
          protocolExpression =
            if protocols == [ ] then
              null
            else if single && ports != [ ] then
              builtins.head protocols
            else if single then
              "meta l4proto ${builtins.head protocols}"
            else
              "meta l4proto ${set protocols}";
          portExpression =
            if ports == [ ] then
              null
            else if single then
              "dport ${set ports}"
            else
              "th dport ${set ports}";
        in
        lib.concatStringsSep " " (
          lib.filter (expression: expression != null) [
            protocolExpression
            portExpression
          ]
        );

      # The number of a value in hexadecimal.
      toHex =
        number:
        let
          digits = "0123456789abcdef";
          go =
            value:
            if value == 0 then
              [ ]
            else
              go (value / 16) ++ [
                (lib.substring (value - (value / 16 * 16)) 1 digits)
              ];
        in
        lib.concatStringsSep "" (go number);

      # The matches of a rule, as the expressions of the ruleset.
      matches =
        family: rule:
        let
          address = if family == "ip6" then "ip6" else "ip";
        in
        lib.concatStringsSep " " (
          lib.filter (expression: expression != null) [
            (if rule.raw != null then lib.trim rule.raw else null)
            (if rule.inbound != [ ] then renderInterfaces "iifname" rule.inbound else null)
            (if rule.outbound != [ ] then renderInterfaces "oifname" rule.outbound else null)
            (if rule.protocol != [ ] || rule.destinationPort != [ ] then
              renderTransport rule.protocol rule.destinationPort
            else
              null)
            (if rule.source != [ ] then renderAddresses family "${address} saddr" rule.source else null)
            (if rule.destination != [ ] then renderAddresses family "${address} daddr" rule.destination else null)
            (if rule.state != [ ] then "ct state ${set rule.state}" else null)
            (if rule.icmpv6Type != [ ] then "icmpv6 type ${set rule.icmpv6Type}" else null)
            (if rule.mark != null then "meta mark 0x${toHex rule.mark}" else null)
            (if rule.ctMark != null then "ct mark 0x${toHex rule.ctMark}" else null)
          ]
        );

      # One rule, as the line of the ruleset.
      renderRule =
        family: rule:
        let
          match = matches family rule;
        in
        "${lib.optionalString (match != "") "${match} "}${lib.optionalString rule.counter "counter "}${rule.action}${lib.optionalString (rule.comment != "") " comment \"${rule.comment}\""}";

      # One chain, as the block of the ruleset.
      renderChain =
        family: role: name: chain:
        let
          hook = lib.elem name hooks;
          type = if role == "nat" then "nat" else "filter";
          priority =
            if chain.priority != null then
              chain.priority
            else if role == "nat" then
              (if name == "postrouting" then "srcnat" else if name == "output" then "100" else "dstnat")
            else if role == "mangle" then
              "mangle"
            else
              "filter";
          defaultRule =
            if chain.defaultAction == null then
              ""
            else
              "counter ${chain.defaultAction} comment \"${name} default-action ${chain.defaultAction}\"";
        in
        ''
          chain ${name} {
            ${lib.optionalString hook "  type ${type} hook ${name} priority ${priority}; policy ${chain.policy};"}
            ${lib.concatMapStringsSep "\n" (rule: "  ${renderRule family rule}") chain.rules}
            ${lib.optionalString (defaultRule != "") "  ${defaultRule}"}
          }
        '';

      # The content of one table, which the module of nftables puts into the
      # table it writes.
      renderTable =
        family: role:
        let
          chains = cfg.rules.${role}.${if family == "ip6" then "ipv6" else "ipv4"};

          # The table of the translation gets a chain of the output, even
          # when it is empty: nftables follows the traffic of the machine
          # itself only in the hooks where the table of the translation is
          # used, and the answers of the machine are dropped without it.
          outputChain =
            if role == "nat" && !(chains ? output) then
              ''
                chain output {
                  type nat hook output priority 100; policy accept;
                }
              ''
            else
              "";
        in
        ''
          ${renderSets family}
          ${outputChain}
          ${lib.concatStringsSep "\n" (lib.mapAttrsToList (name: chain: renderChain family role name chain) chains)}
        '';
    in
    {
      options.firewall = {
        groups = {
          interface = lib.mkOption {
            type = groupType;
            default = { };
            description = "The interface groups, matched as the sets `I_<name>`.";
          };
          address = lib.mkOption {
            type = groupType;
            default = { };
            description = "The address groups, matched as the sets `A_<name>` and `A6_<name>`.";
          };
          network = lib.mkOption {
            type = groupType;
            default = { };
            description = "The network groups, matched as the sets `N_<name>` and `N6_<name>`.";
          };
          mac = lib.mkOption {
            type = groupType;
            default = { };
            description = "The mac address groups, matched as the sets `M_<name>`.";
          };
        };

        rules = {
          filter = lib.mkOption {
            type = familyType;
            default = { };
            description = "The rules of the filter table.";
          };
          nat = lib.mkOption {
            type = familyType;
            default = { };
            description = "The rules of the nat table.";
          };
          mangle = lib.mkOption {
            type = familyType;
            default = { };
            description = ''
              The rules of the mangle table, which carry the marks of the
              policy routing.
            '';
          };
        };
      };

      config = {
        networking.nftables.enable = true;

        # The ruleset of the module is the firewall of the host.
        networking.firewall.enable = false;

        networking.nftables.tables = {
          filter = {
            family = "ip";
            content = renderTable "ip" "filter";
          };
          filter6 = {
            family = "ip6";
            content = renderTable "ip6" "filter";
          };
          nat = {
            family = "ip";
            content = renderTable "ip" "nat";
          };
          nat6 = {
            family = "ip6";
            content = renderTable "ip6" "nat";
          };
          mangle = {
            family = "ip";
            content = renderTable "ip" "mangle";
          };
          mangle6 = {
            family = "ip6";
            content = renderTable "ip6" "mangle";
          };
        };
      };
    };
}
