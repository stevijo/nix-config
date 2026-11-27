{ ... }:

{
  nixos.configurations.vyos.module = { config, lib, pkgs, ... }: {
    config.tunnel = {
      count = 3;
      side = "local";
    };
  };
}
