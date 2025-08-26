See README.md for project info.

## Code generation

- The `src/Web/TablerIcons` modules are generate by our code generator in `codegen.hs`.
- The code generator traverses the "tabler-icons" flake input, and generates the Haskell module.
- The code generator can be run using `nix run .#tabler-codegen`.
- The Haddock docs can be generated using `cabal haddock all` in the Nix devShell.