# The system level settings of the Ally.
{ ... }:

{
  nixos.configurations.ally.module = { pkgs, ... }: {
    environment.systemPackages = with pkgs; [ vim ];

    services.openssh = {
      enable = true;
      settings.PasswordAuthentication = false;
    };
  };
}
