# Like GNU `make`, but `just` rustier.
# https://just.systems/
# run `just` from this directory to see available commands

# Default command when 'just' is run without arguments
default:
  @just --list

# Update nix flake
[group('Main')]
update:
  nix run .#update

# Lint nix files
[group('dev')]
lint:
  nix fmt -- .

# Manually enter dev shell
[group('dev')]
dev:
  nix develop

# Activate the configuration
[group('Main')]
@run *args:
    nix run . {{args}}

# Run this after editing .sops.yaml
[group('Main')]
sops-updatekeys:
    find . -type f -iname secrets.yaml -exec sops updatekeys {} \;
