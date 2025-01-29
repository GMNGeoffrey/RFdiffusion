# RFDiffusion on AMD GPU

Brief instructions for running RFDiffusion on AMD GPU using DGL ported to use
HIP (in https://github.com/nod-ai/dgl).

## Docker

The dockerfile is at [./Dockerfile.rocm].

To build the docker container:

```shell
docker build -t rfdiffusion-dgl-rocm - <Dockerfile.rocm
```

To run the docker container:

```shell
docker run -it \
    --network=host \
    --device=/dev/kfd \
    --device=/dev/dri \
    --ipc=host \
    --shm-size 16G \
    --group-add video \
    --cap-add=SYS_PTRACE \
    --security-opt \
    seccomp=unconfined \
    rfdiffusion-dgl-rocm
```

This will give you a bash shell in the `/rfidffusion` directory (a clone of the
RFDiffusion git repository).

This is just an example. For official docs, see
https://rocm.docs.amd.com/projects/install-on-linux/en/latest/how-to/docker.html


## Dependencies

The Docker container is going to be the most reliable documentation of the
dependencies, but generally you need the latest ROCM plus two header-only
patches: https://github.com/ROCm/rocPRIM/pull/662 (don't need the test update)
and https://github.com/ROCm/hipCUB/pull/433. If you are setting up a local
machine, I highly recommend using a Python virtual environment.

## DGL

DGL has been ported to work with HIP in
https://github.com/nod-ai/dgl/tree/hipify-inplace. Only the PyTorch backend is
supported and distributed multi-GPU execution is not supported, but otherwise
all C++ and Python unit tests pass. You can run them as:

```shell
cd /dgl
# C++ Tests
build/runUnitTests
# Python GPU tests
bash ./script/run_pytest.sh -g \
    tests/python/pytorch/ \
    --ignore=tests/python/pytorch/graphbolt \
    --ignore=tests/python/pytorch/distributed \
    --deselect=tests/python/pytorch/dataloading/test_dataloader.py::test_distributed_dataloaders
bash ./script/run_pytest.sh -g \
    tests/python/common/ \
    --ignore=tests/python/common/test_partition.py

# Python CPU tests
bash ./script/run_pytest.sh -c \
    tests/python/pytorch/ \
    --ignore=tests/python/pytorch/graphbolt \
    --ignore=tests/python/pytorch/distributed \
    --deselect=tests/python/pytorch/dataloading/test_dataloader.py::test_distributed_dataloaders
bash ./script/run_pytest.sh -c \
    tests/python/common/ \
    --ignore=tests/python/common/test_partition.py
```

The Docker container contains a release build.

### Building from source

You can base a source build off of the command in the Docker container. Note the
usage of clang-19. This is required to pick up
https://github.com/llvm/llvm-project/pull/93976. If need to debug, you may want
to do a debug build. Set `-DCMAKE_BUILD_TYPE=Release -DBUILD_TYPE=release`. If
you're rebuilding a lot, I recommend using [ccache](https://ccache.dev/). Set
`-DCMAKE_C_COMPILER_LAUNCHER=ccache -DCMAKE_CXX_COMPILER_LAUNCHER=ccache`. If
building in a virtual environment, I strongly recommend
`-DPython3_FIND_VIRTUALENV=ONLY`.

## RFDiffusion

I've added a few minor patches to RFDiffusion: updating SE3Transformer to the
latest from upstream and commenting out a couple of NVIDIA-specific
dependencies. Running RFDiffusion should work as described in the README. The
Conda environment setup is specific to CUDA (and a specific version thereof), so
when working locally I just used a virtual environment and installed
dependencies with pip.

The docker container should have everything you need and you should be able to
jump straight to the [README Usage section](./README.md#usage).

