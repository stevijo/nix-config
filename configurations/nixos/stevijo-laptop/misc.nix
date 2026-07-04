# Misc one-off enables: hardware.ledger for udev rules so the Ledger
# wallet is accessible to user-space tools without root, and Wireshark
# for packet capture with the wireshark group.
{ pkgs, ... }:

{
  hardware.ledger.enable = true;

  programs.wireshark = {
    enable = true;
    package = pkgs.wireshark;
  };
}
