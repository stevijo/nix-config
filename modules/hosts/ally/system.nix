# The system level settings of the Ally.
{ ... }:

{
  flake.modules.nixos."nixosConfigurations/ally" = { pkgs, ... }: {
    environment.systemPackages = with pkgs; [ vim ];

    services.openssh = {
      enable = true;
      settings.PasswordAuthentication = false;
    };
  };
}
