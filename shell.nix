{ pkgs ? (import ./nix/pkgs.nix).pkgs, ... }:

let
  hipsycl = import ./nix/hipsycl.nix { };

  hacky-hipsycl-cuda-wrapper = pkgs.writeScriptBin "hipsycl-cuda" ''
    #!/usr/bin/env bash
    ${hipsycl}/bin/syclcc-clang  -L${pkgs.cudaPackages.cudatoolkit_10_1.lib}/lib --hipsycl-platform=cuda --hipsycl-gpu-arch=sm_52 "$@"
  '';

  hacky-hipsycl-cpu-wrapper = pkgs.writeScriptBin "hipsycl-cpu" ''
    #!/usr/bin/env bash
    ${hipsycl}/bin/syclcc-clang  -L${pkgs.llvmPackages_9.openmp}/lib -I${pkgs.llvmPackages_9.openmp}/include --hipsycl-platform=cpu "$@"
  '';

in pkgs.stdenvNoCC.mkDerivation rec {
  name = "sycl-env";
  env = pkgs.buildEnv { name = name; paths = buildInputs; };

  buildInputs = [
    hipsycl

    hacky-hipsycl-cuda-wrapper
    hacky-hipsycl-cpu-wrapper
  ];

  shellHook = ''
    export NIX_SHELL_NAME="${name}"
  '';
}
