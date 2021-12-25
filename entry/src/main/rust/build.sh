#!/usr/bin/env bash

set -e
set -o pipefail

if [ "$#" -ne 2 ]; then
    echo "Illegal number of parameters"
    echo "Usage: $0 <build_type> <arch_abi>"
    exit 1
fi

build_type=$1
arch_abi=$2

working_dir=$PWD
build_dir="${working_dir}"/.rust/"${build_type}/${arch_abi}"
output_dir="${working_dir}"/libs/"${arch_abi}"
rust_source_root="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

echo "[RustLibBuilder] working_dir = ${working_dir}"
echo "[RustLibBuilder] build_dir = ${build_dir}"
echo "[RustLibBuilder] output_dir = ${output_dir}"
echo "[RustLibBuilder] rust_source_root = ${rust_source_root}"


mkdir -p "$build_dir"
mkdir -p "$output_dir"

cd "${rust_source_root}"

if [[ "${build_type}" = "Release" ]]; then
    cargo +nightly build \
      -Z unstable-options --release --lib \
      --target-dir "$build_dir" \
      --out-dir "$output_dir"   \
      -Zbuild-std=panic_abort,std \
      --target aarch64-linux-ohos.json
else
    cargo +nightly build \
      -Z unstable-options --lib \
      --target-dir "$build_dir" \
      --out-dir "$output_dir"   \
      -Zbuild-std=panic_abort,std \
      --target aarch64-linux-ohos.json
fi

