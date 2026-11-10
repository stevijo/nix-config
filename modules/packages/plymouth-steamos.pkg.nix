# The SteamOS boot splash, as a plymouth theme.
#
# Jovian ships the same theme in `steamdeck-hw-theme`, but that package
# pulls in the whole Steam runtime, and with it the initrd. This is the
# theme with just the three files it needs. The image is Valve's, so this
# is unfree.
{ fetchurl, runCommand }:

let
  base = "https://raw.githubusercontent.com/Jovian-Experiments/jupiter-hw-support/jupiter-20260930.1/usr/share/plymouth/themes/steamos";

  hashes = {
    "steamos.plymouth" = "sha256-6dz4SK4O3HiBWV2sm5oEnG49AfGpIyMZq8cXZy8r5+Y=";
    "steamos.script" = "sha256-urN7EzP24ObHSDIyYvlhu3SiVrtqW8eOy7QgDRgANmU=";
    "steamos.png" = "sha256-1ga7Hg3Bu2FPgVbPoa3ajt9ORhM6TfohBOjV0uJcWw4=";
  };

  fetch = file: fetchurl {
    url = "${base}/${file}";
    hash = hashes.${file};
  };
in
runCommand "plymouth-steamos" { } ''
  mkdir -p $out/share/plymouth/themes/steamos
  cp ${fetch "steamos.plymouth"} $out/share/plymouth/themes/steamos/steamos.plymouth
  cp ${fetch "steamos.script"} $out/share/plymouth/themes/steamos/steamos.script
  cp ${fetch "steamos.png"} $out/share/plymouth/themes/steamos/steamos.png

  # The theme refers to its images by absolute path.
  sed -i "s|/usr/|$out/|g" $out/share/plymouth/themes/steamos/steamos.plymouth
''
