# Power management: TLP for laptops, thermald for Intel thermal throttling,
# and the NixOS powerManagement target which enables power-profiles etc.
{ ... }:

{
  services.tlp.enable = true;
  powerManagement.enable = true;
  services.thermald.enable = true;
}
