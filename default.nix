let

  sundialsOverlay = self: super:
    {
      sundials1 = self.callPackage ./CustomSundials { };
    };

  nixpkgs = fetchTarball {
    url = "https://github.com/NixOS/nixpkgs/archive/22.05.tar.gz";
    sha256 = "sha256:0d643wp3l77hv2pmg2fi7vyxn4rwy0iyr8djcw1h5x72315ck9ik";
  };

in

{ pkgs ? import nixpkgs { overlays = [ sundialsOverlay ]; }
, compiler ? "default"
, doBenchmark ? false
}:

let

  variant = if doBenchmark then pkgs.haskell.lib.doBenchmark else pkgs.lib.id;
  haskellPackages =
    if compiler == "default"
    then pkgs.haskellPackages
    else pkgs.haskell.packages.${compiler};

in
variant
  (haskellPackages.callCabal2nix "hmatrix-sundials" ./. {
    klu = pkgs.suitesparse;
    suitesparseconfig = pkgs.suitesparse;
    sundials_arkode = pkgs.sundials1;
    sundials_cvode = pkgs.sundials1;
    sundials_sunlinsolklu = pkgs.sundials1;
    sundials_sunmatrixsparse = pkgs.sundials1;
  })
  // { inherit haskellPackages; }
