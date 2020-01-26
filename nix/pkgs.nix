{
  # fixing the nixpkgs-unstable version used to build custom LLVM and clang to prevent unnecessary rebuilds
  pkgs = import (builtins.fetchTarball {
    name = "nixos-unstable-for-custom-llvm-build";
    url = https://github.com/nixos/nixpkgs/archive/7e8454fb856573967a70f61116e15f879f2e3f6a.tar.gz;
    sha256 = "0lnbjjvj0ivpi9pxar0fyk8ggybxv70c5s0hpsqf5d71lzdpxpj8";
  }) { };

  ## uncomment to use your own local nixpkgs channel
  #pkgs = import <nixpkgs-unstable> { };
}
