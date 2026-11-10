# The user account of the laptop.
{ ... }:

{
  nixos.configurations.stevijo-laptop.module = { ... }: {
    users.users.stevijo = {
      extraGroups = [ "video" "docker" "adbusers" "wireshark" "dialout" ];
    };
  };
}
