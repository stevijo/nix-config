{ ... }:

{
  nixos.configurations.bigbox.module = { config, lib, pkgs, ... }: {
    config.tunnel = {
      count = 3;
      side = "remote";
    };
  };
}
