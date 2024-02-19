{ runCommand
, symlinkJoin
, makeWrapper
, strongswan
}:
let
  patchedStrongswan = strongswan.overrideAttrs (old: {
    configureFlags = old.configureFlags ++ [
      "--enable-libipsec"
    ];
    patches = old.patches ++ [
      ./0001-make-plugin-dir-configurable.patch
    ];
  });
  # creates a new derivation that wraps the package binary and attaches to the plugins somehow.
  withPlugins = plugins:
    # some time it's possible to reference all the plugins individually
    # if they all need to live in a folder then use symlinkJoin
    let
      pluginsRef = symlinkJoin {
        name = "${pkg.name}-plugins";
        paths = [ patchedStrongswan ] ++ plugins;
      };

      wrapped = runCommand "${pkg.name}-with-plugins"
        {
          buildInputs = [ makeWrapper ];
        } ''
        for cmd in charon-cmd charon-systemd ipsec pki swanctl; do
          makeWrapper ${patchedStrongswan}/bin/$cmd $out/bin/$cmd \
            --set PLUGINDIR "${pluginsRef}/lib/ipsec/plugins"
        done

      '';
    in
    symlinkJoin {
      name = "${pkg.name}-combined";
      passthru.withPlugins = moarPlugins: withPlugins (moarPlugins ++ plugins);
      paths = [
        wrapped
        pluginsRef
      ];
    };
  pkg = patchedStrongswan.overrideAttrs {
    passthru = {
      inherit withPlugins;
    };
  };
in
pkg.withPlugins [ ]
