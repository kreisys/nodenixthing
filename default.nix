{ pkgs ? import <nixpkgs> {}
, supplemental ? {}
, idRsa ? ""
, npmRc ? ""
, npmPkgOpts ? {}
, preBuild ? ""
, env ? {}
, src
}:

with builtins;
with pkgs;
with pkgs.lib;
with (callPackage ./util.nix {});
let
  package = importJSON "${src}/package.json";
  lock    = importJSON "${src}/npm-shrinkwrap.json";

  inherit (package) name version;

  npmFetch = callPackage ./npm/fetch.nix { inherit idRsa npmRc; };

  mkContext = callPackage ./context {};
  doMagic = callPackage ./magic.nix { inherit npmFetch; };
  doWitchcraft = callPackage ./witchcraft.nix {};
  doKabala = callPackage ./kabala.nix {};
  castSpells = callPackage ./spells.nix {};
  makeUnicorn = callPackage ./unicorns.nix {};

  contextJson = mkContext { inherit package lock supplemental; };
  fetchedContextJson = doMagic { inherit contextJson; };
  extractedContextJson = doWitchcraft { contextJson = fetchedContextJson; inherit src; };
  processedContextJson = doKabala { contextJson = extractedContextJson; inherit src; };
  builtContext = castSpells { contextJson = processedContextJson; inherit env npmPkgOpts src preBuild; };
in builtContext.${name}.${version}.path
