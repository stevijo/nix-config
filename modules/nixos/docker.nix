# Docker, for hosts which run containers.
{ ... }:

{
  flake.modules.nixos.docker = {
    virtualisation.docker.enable = true;
  };
}
