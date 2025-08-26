{
  description = "Nix template for Haskell projects";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    nixos-unified.url = "github:srid/nixos-unified";
    haskell-flake.url = "github:srid/haskell-flake";

    git-hooks.url = "github:cachix/git-hooks.nix";
    git-hooks.flake = false;

    tabler-icons.url = "github:tabler/tabler-icons";
    tabler-icons.flake = false;
  };

  outputs = inputs:
    # This will import ./nix/modules/flake/*.nix
    # cf. https://nixos-unified.org/autowiring.html#flake-parts
    #
    # To write your own Nix, add or edit files in ./nix/modules/flake/
    inputs.nixos-unified.lib.mkFlake
      { inherit inputs; root = ./.; };
}
