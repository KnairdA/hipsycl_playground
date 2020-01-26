{ pkgs ? (import ./pkgs.nix).pkgs, ... }:

let
  custom-llvm = pkgs.llvm_9.overrideAttrs (old: {
    cmakeFlags = old.cmakeFlags ++ [
      "-DLLVM_ENABLE_RTTI=ON"
    ];
  });

  custom-clang-unwrapped = pkgs.llvmPackages_9.clang-unwrapped.overrideAttrs (old: {
    cmakeFlags = old.cmakeFlags ++ [
      "-DLLVM_ENABLE_RTTI=ON"
    ];
  });

  custom-clang = pkgs.llvmPackages_9.clang.override {
    cc = custom-clang-unwrapped;
  };

in (pkgs.overrideCC pkgs.stdenvNoCC custom-clang).mkDerivation rec {
  name = "hipsycl";

  src = pkgs.fetchFromGitHub  { 
    owner = "illuhad"; 
    repo = "hipSYCL"; 

    #rev  = "v0.8.0";
    #sha256 = "08pqkjpkyp8cakky7gd19ihq6908wfjh1gbvc98frw9sywhrw0cm";

    rev = "a0d185fe48f7751bceff83c84e57547e00936349";
    sha256 = "0l39pr7p5dxicrp5pkp15wlb3m5l7gyqs4akjg293jsiga2h48si";

    fetchSubmodules = true;
  };

  buildInputs = with pkgs; [
    cmake
    boost
    python3

    custom-clang
    custom-llvm

    cudaPackages.cudatoolkit_10_1
    linuxPackages.nvidia_x11 

    llvmPackages_9.openmp
  ];

  cmakeFlags = ''
    -DCLANG_INCLUDE_PATH=${custom-clang-unwrapped}/include
    -DLLVM_ENABLE_RTTI=ON

    -DWITH_CPU_BACKEND=ON

    -DWITH_CUDA_BACKEND=ON
    -DCUDA_TOOLKIT_ROOT_DIR=${pkgs.cudaPackages.cudatoolkit_10_1}/
  '';

  preConfigure = ''
    export CXXFLAGS="$CXXFLAGS -I${custom-clang-unwrapped}/include -I${custom-llvm}/include --cuda-path=${pkgs.cudaPackages.cudatoolkit_10_1} -D_FORTIFY_SOURCE=0"
  '';

  preBuild = ''
    patchShebangs /build/source/bin/syclcc
    patchShebangs /build/source/bin/syclcc-clang
    patchShebangs /build/source/auto-test/build.py
  '';
}
