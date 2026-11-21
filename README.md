# nix-config

Personal NixOS, nix-darwin and home-manager configuration, written in the
[dendritic pattern](https://github.com/mightyiam/dendritic): every file below
`modules/` is a top-level (flake-parts) module of one shared configuration,
and the lower-level modules (NixOS, home-manager, nix-darwin) live in the
shared namespace, where they can be composed and reused.

```
flake.nix                 the entry point
justfile                  the commands of this repository
modules/                  the dendritic tree, every .nix file is a module
  nixos.nix               the NixOS namespace, builds the NixOS hosts
  nix-darwin.nix          the nix-darwin namespace, builds the macOS hosts
  home-manager.nix        the home-manager namespace and its integration
  base.nix                the settings shared by every configuration
  profiles.nix            the home-manager profiles of Linux and macOS
  sway/                   the sway desktop, system and user side
  shell/                  zsh, starship, direnv, k9s
  jovian.nix + jovian/    the Steam Deck experience of the Ally
  neovim.nix + neovim/    neovim and its lua configuration
  users/                  the home-manager settings of each user
  docker.nix, sops.nix, kitty.nix, fontconfig.nix
  firewall.nix            the nftables rulesets of the routers
  vpp.nix + _vpp/         the module of VPP, which is not in nixpkgs yet, and
                          the overlay of its patched package
  hosts/                  the hosts and their settings
  lib/pkgs.nix            the package set of the per-system outputs
  activate.nix + activate/  the activation script and its module
  packages.nix + packages/  the packages and their callPackage files
  scripts/               the check of the configurations of the routers
  devshell.nix, update.nix, formatter.nix, overlays.nix
```

## Loading the modules

The files are found with
[import-tree](https://github.com/denful/import-tree), which imports every
`.nix` file below `modules/` as a module of this configuration:

```nix
# flake.nix
imports = [
  ((import inputs.import-tree).filterNot (lib.hasSuffix ".pkg.nix") ./modules)
];
```

Two kinds of files are not modules of this configuration and are therefore
skipped: the callPackage files, which end in `.pkg.nix`, and the content of
the directories whose name starts with an underscore.

## The namespace of the lower-level modules

The lower-level modules are stored in options of this configuration, one
namespace per kind of configuration:

| option                       | holds                                            |
| ---------------------------- | ------------------------------------------------ |
| `nixos.modules`              | the NixOS features, keyed by feature name         |
| `nixos.configurations`       | the NixOS hosts                                   |
| `homeManager.modules`        | the home-manager features                         |
| `nixDarwin.modules`          | the nix-darwin features                           |
| `nixDarwin.configurations`   | the nix-darwin hosts                              |

The tree is organised by feature, not by kind of configuration. A feature is
written by the module which implements it, and that module sets every kind of
configuration the feature touches:

```nix
# modules/sway/sway.nix
{
  nixos.modules.sway = { ... }: {
    programs.sway.enable = true;
  };

  homeManager.modules.sway = { ... }: {
    wayland.windowManager.sway.enable = true;
  };
}
```

A feature can be written by more than one file, in which case the modules
are merged (`modules/sway/rofi.nix` adds to `homeManager.modules.sway`). The options are declared next to the features they hold, in
`modules/nixos.nix`, `modules/home-manager.nix` and `modules/nix-darwin.nix`,
which also build the configurations of the flake.

## The hosts

A host is written by the module of the same name in `modules/hosts/`, its
settings live in `modules/hosts/<name>/`:

```nix
# modules/hosts/router.nix
{
  nixos.configurations.router = {
    sshTarget = "stevijo@router";
    module = { config, ... }: {
      imports = [ base docker home-manager sops ];
    };
  };
}
```

Besides its `module`, a host carries the metadata which is needed to build
and to activate it: the `platform`, the `nixpkgs` and `homeManager` to build
it with, and the `sshTarget` used to activate it remotely.

A host may also have an `extensions` module. It is applied after the host
itself and gets `prev` bound to the host without it, which is how the
templates of the secrets read the file they replace.

The home-manager configuration of a host is part of its system: home-manager
runs inside NixOS and nix-darwin, so activating a host activates the home
configuration of its users as well.

| host             | kind       | platform       | notes                                          |
| ---------------- | ---------- | -------------- | ---------------------------------------------- |
| `router`         | nixos      | x86_64-linux   | routes and terminates the IPsec tunnel          |
| `ally`           | nixos      | x86_64-linux   | runs nixos-unstable, for the Jovian vendor packages |
| `stevijo-laptop` | nixos      | x86_64-linux   | the Framework 13                               |
| `G56K599LK7`     | nix-darwin | aarch64-darwin | the macOS machine                              |
| `vyos`           | nixos      | x86_64-linux   | the router at the edge of the network, which runs the packet processor |

### The secrets of the routers

The public addresses of the routers, the prefixes of the provider, the number
of the autonomous system and the keys are not part of the configuration. They
live in the encrypted file `modules/hosts/<host>/secrets.yaml`, which sops
writes to `/run/secrets` when the system starts.

The configuration files of the services are written with placeholders instead
of the values, and the templates of sops rewrite them with the secrets when
the system starts, under `/run/secrets/rendered`. The ruleset of nftables is
the exception: it is written by the unit, so the unit is replaced by the one
which reads the rendered file.

The addresses of the interfaces are set by the units of systemd, which read
them from the secrets when they run, because the addresses themselves cannot
be part of the configuration of an interface.

### The console of the routers

The routers are only reachable over the network, and the faster-router is
only reachable over its own public address, so the console is the way in
when the network is down.

The console is the serial port of the machine: the port of the machine
(`ttyS0`), which is the port of a virtual machine and of a server, and the
port of the management controller (`ttyUSB0`), which is reached with IPMI.
The kernel writes to both of them and there is a getty on each of them.

The account of the console is `stevijo`, with the key of the age key, which
the router needs anyway to decrypt its secrets. Its password is the secret
`console-password`, which is set on the account when the system starts.

```sh
ipmitool -I lanplus -U <user> sol activate   # the console of the controller
```

The age key has to be on the router before the first activation, otherwise
the secrets cannot be decrypted and the activation fails. It is the key of
the user, at `/home/stevijo/.ssh/id_ed25519`.

### The package of VPP

The package of VPP is patched: the patches of VyOS and the ones of this
configuration are applied to it. The patch of VyOS is a list which is fetched
with the sources, the patches of this configuration live in
`modules/packages/vpp/`.

The patch is applied with an overlay, which is only added to the systems which
enable the service of VPP. The package is built from the sources and takes a
long time, so the systems which do not use it do not pull it in.

## Applying the configuration

```sh
just run              # activate the configuration of this machine
just run <host>       # activate the configuration of another host, over SSH
```

The activation script lives in `modules/activate/activate.nu` and is adapted
from [nixos-unified](https://github.com/srid/nixos-unified) (MIT).

## Working on this configuration

```sh
just dev      # the devshell
just lint     # format the nix files
just check    # check the flake
just update   # update the flake inputs
```

A git flake only sees the files which are tracked by git, so a new module has
to be added (`git add`) before the flake picks it up.
