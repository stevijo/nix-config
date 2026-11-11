# Docker, for hosts which run containers.
{ ... }:

{
  nixos.modules.docker = {
    virtualisation.docker.enable = true;
  };
}
