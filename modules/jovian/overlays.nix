{ ... }:

{
  nixos.modules.jovian = { ... }: {
    nixpkgs.overlays = [
      (self: super: {
        jovianPackages = super.jovianPackages // {
          steamos-manager = super.jovianPackages.steamos-manager.overrideAttrs (oldAttrs: {

            patches = oldAttrs.patches ++ [
              ./0004-ally-x.patch
            ];
          });
          inputplumber = self.callPackage
            ({ inputplumber'
             , fetchFromGitHub
             , rustPlatform
             ,
             }:
              inputplumber'.overrideAttrs (oldAttrs: rec {
                version = "0.83.1";

                src = fetchFromGitHub {
                  owner = "ShadowBlip";
                  repo = "InputPlumber";
                  tag = "v${version}";
                  hash = "sha256-2NAIiIZBi1lZdPPND6VCihThvdHd1aJ2X6ZArinIL2E=";
                };

                cargoDeps = rustPlatform.fetchCargoVendor {
                  inherit src;
                  hash = "sha256-d5sW/w5JolX20U2OzGHMDcUXi0+hvXV0kKWXD2FfIKA=";
                };
              }))
            {
              inputplumber' = super.jovianPackages.inputplumber;
            };

        };

      })
    ];
  };
}
