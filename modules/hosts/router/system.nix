# The system level settings of the router: SSH, the user account and the
# packages of the system profile.
{ ... }:

{
  nixos.configurations.router.module = { lib, pkgs, ... }: {
    environment.systemPackages = with pkgs; [
      git
      acpi
      python3
      nodejs_24
      sysstat
      vim
    ];

    services.openssh = {
      enable = true;
      settings = {
        PasswordAuthentication = false;
      };
    };
    networking.firewall.enable = false;

    services.fwupd.enable = true;

    users.users.stevijo = {
      extraGroups = [ "video" "docker" ];
    };
    security.sudo.extraRules = [
      {
        users = [ "stevijo" ];
        commands = [
          {
            command = "ALL";
            options = [ "NOPASSWD" ]; # "SETENV" # Adding the following could be a good idea
          }
        ];
      }
    ];
  };
}
