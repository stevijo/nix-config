# nix-config

Personal NixOS, nix-darwin and home-manager configuration, written in the
[dendritic pattern](https://github.com/mightyiam/dendritic): every file below
`modules/` is a top-level (flake-parts) module of one shared configuration,
and the lower-level modules (NixOS, home-manager, nix-darwin) live in the
`flake.modules` namespace, where they can be composed and reused.

```
flake.nix                 the entry point
justfile                  the commands of this repository
modules/                  the dendritic tree, every .nix file is a module
  generic/                features which apply to any configuration class
  nixos/                  features which apply to NixOS
  home-manager/           features which apply to home-manager
  darwin/                 features which apply to nix-darwin
  hosts.nix + hosts/      the hosts and their settings
  lib/                    the builders of the configurations
  activate.nix + activate/  the activation script and its module
  packages.nix + packages/  the packages and their callPackage files
  devshell.nix, update.nix, formatter.nix, overlays.nix
```

## The namespace of the lower-level modules

`flake.modules` is declared by flake-parts itself
(`inputs.flake-parts.flakeModules.modules`). Its outer attribute names the
*class* of the modules, the inner one the feature:

```nix
# modules/nixos/docker.nix
{
  flake.modules.nixos.docker = {
    virtualisation.docker.enable = true;
  };
}
```

A feature can be defined in more than one file, in which case the modules are
merged. The classes are `generic` (usable in any configuration), `nixos`,
`homeManager` and `darwin`. A class has to match the class of the module
system it is imported into, which is why the nix-darwin features live in
`darwin` and not in `nix-darwin`.

Two kinds of files below `modules/` are not modules of this configuration and
are therefore skipped by the automatic import: the callPackage files, which
end in `.pkg.nix`, and the content of the directories whose name starts with
an underscore.

## The hosts

A host is a feature as well. Its settings live in
`flake.modules.<class>."<kind>Configurations/<host>"`, and
`modules/lib/nixos.nix` (respectively `modules/lib/darwin.nix`) turns those
into the `nixosConfigurations` (respectively `darwinConfigurations`) of the
flake:

```nix
# modules/hosts/router.nix
{
  flake.modules.nixos."nixosConfigurations/router" = { config, ... }: {
    imports = [ base docker home-manager sops ];
  };
}
```

A host may also have an *extension*, in
`flake.modules.nixos."nixosExtensions/<host>"`. It is applied after the host
itself and gets `prev` bound to the system without it, which is how the
scalpel transformation reads the file it replaces.

The metadata of the hosts — the platform, the nixpkgs to build them with, the
home-manager to use, the SSH target of the activation — lives in the `hosts`
option, which is declared in `modules/hosts.nix` and filled in by the module
of each host.

| host            | kind      | platform       | notes                                |
| --------------- | --------- | -------------- | ------------------------------------ |
| `router`        | nixos     | x86_64-linux   | routes and terminates the IPsec tunnel |
| `ally`          | nixos     | x86_64-linux   | runs nixos-unstable, for the Jovian vendor packages |
| `stevijo-laptop`| nixos     | x86_64-linux   | the Framework 13                     |
| `G56K599LK7`    | nix-darwin| aarch64-darwin | the macOS machine                    |

## Applying the configuration

```sh
just run                 # activate the configuration of this machine
just run <host>          # activate the configuration of another host, over SSH
just run <user>@<host>   # activate the home configuration of a user
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
