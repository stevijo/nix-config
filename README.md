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
  nixos.nix               the NixOS features and hosts
  home-manager.nix        the home-manager features
  nix-darwin.nix          the nix-darwin features and hosts
  nixos/                  the NixOS features
  home-manager/           the home-manager features
  darwin/                 the nix-darwin features
  generic/                the settings shared by every configuration
  hosts/                  the hosts and their settings
  lib/pkgs.nix            the package set of the per-system outputs
  activate.nix + activate/  the activation script and its module
  packages.nix + packages/  the packages and their callPackage files
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

A feature is written by the module which implements it:

```nix
# modules/nixos/docker.nix
{
  nixos.modules.docker = {
    virtualisation.docker.enable = true;
  };
}
```

A feature can be written by more than one file, in which case the modules
are merged. The options are declared next to the features they hold, in
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
itself and gets `prev` bound to the host without it, which is how the scalpel
transformation reads the file it replaces.

The home-manager configuration of a host is part of its system: home-manager
runs inside NixOS and nix-darwin, so activating a host activates the home
configuration of its users as well.

| host             | kind       | platform       | notes                                          |
| ---------------- | ---------- | -------------- | ---------------------------------------------- |
| `router`         | nixos      | x86_64-linux   | routes and terminates the IPsec tunnel          |
| `ally`           | nixos      | x86_64-linux   | runs nixos-unstable, for the Jovian vendor packages |
| `stevijo-laptop` | nixos      | x86_64-linux   | the Framework 13                               |
| `G56K599LK7`     | nix-darwin | aarch64-darwin | the macOS machine                              |

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
