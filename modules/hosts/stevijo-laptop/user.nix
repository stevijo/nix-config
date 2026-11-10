# The user account of the laptop.
{ ... }:

{
  flake.modules.nixos."nixosConfigurations/stevijo-laptop" = { ... }: {
    users.users.stevijo = {
      extraGroups = [ "video" "docker" "adbusers" "wireshark" "dialout" ];
    };
  };
}
