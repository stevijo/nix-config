# User account extra groups + home-manager wiring for the "stevijo" user.
{ flake, ... }:

let
  inherit (flake) inputs;
  inherit (inputs) self;
in
{
  users.users.stevijo = {
    extraGroups = [ "video" "docker" "adbusers" "wireshark" "dialout" ];
  };

  home-manager.users."stevijo" = {
    imports = [ (self + "/configurations/home/stevijo@stevijo-laptop.nix") ];
  };
}
