# hipSYCL playground for NixOS

…so this took way longer to set up than it should have, e.g. I had to do not one but multiple full rebuilds of Clang and LLVM from source.
At this point the derivations in this repository produce a working version of hipSYCL's CPU backend and at least a compiling and linking version of its CUDA backend.

i.e. you can do:

```sh
> nix-shell
> hipsycl-cpu vadd.cc -o vadd
> ./vadd
Running on hipCPU OpenMP host device

Result:
10 10 10 10 10 10 10 10 10 10 
>
```

Doing the same with `hipsycl-cuda` (a small wrapper around syclcc-clang to add some includes) should yield an executable without any warnings but sadly it currently doesn't seem to actually do anything on the GPU. This seems to be related to [issue 49](https://github.com/illuhad/hipSYCL/issues/49) so let's see where that goes.
