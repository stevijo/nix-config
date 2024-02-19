{ lib, ... }:
{
  flake.nix-config.lib = rec {
    scalpelFile = "scalpel.nix";
    mapAttrsMaybe = f: attrs:
      lib.pipe attrs [
        (lib.mapAttrsToList f)
        (builtins.filter (x: x != null))
        builtins.listToAttrs
      ];
    forAllNixFiles = dir: f:
      if builtins.pathExists dir then
        lib.pipe dir [
          builtins.readDir
          (mapAttrsMaybe (fn: type:
            if type == "regular" then
              let name = lib.removeSuffix ".nix" fn; in
              lib.nameValuePair name (f { path = "${dir}/${fn}"; })
            else if type == "directory" && builtins.pathExists "${dir}/${fn}/default.nix" then
              if builtins.pathExists "${dir}/${fn}/${scalpelFile}" then
                lib.nameValuePair fn (f { path = "${dir}/${fn}"; scalpel = true; })
              else
                lib.nameValuePair fn (f { path = "${dir}/${fn}"; })
            else
              null
          ))
        ] else { };
  };
}
   