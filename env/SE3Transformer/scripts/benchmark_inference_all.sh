#!/usr/bin/env bash
# Script to benchmark inference performance, without bases precomputation

EPOCHS=10

for amp in true false; do
    for batch_size in 400 800 1600; do
        echo "Benchmarking inference batch_size=${batch_size}, amp=${amp}"
        python -m se3_transformer.runtime.inference \
            --amp "${amp}" \
            --batch_size "${batch_size}" \
            --use_layer_norm \
            --norm \
            --task homo \
            --seed 42 \
            --benchmark \
            --epochs "${EPOCHS}"
        echo "Done benchmarking inference batch_size=${batch_size}, amp=${amp}"
    done
done
