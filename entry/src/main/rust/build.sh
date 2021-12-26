#!/usr/bin/env bash

set -e
set -o pipefail

if [ "$#" -ne 3 ]; then
    echo "Illegal number of parameters"
    echo "Usage: $0 <ndk_dir> <build_type> <arch_abi>"
    exit 1
fi

ndk_dir=$1
build_type=$2
arch_abi=$3

echo "[RustLibBuilder] ndk_dir = ${ndk_dir}"
echo "[RustLibBuilder] build_type = ${build_type}"
echo "[RustLibBuilder] arch_abi = ${arch_abi}"

working_dir=$PWD
build_dir="${working_dir}/.rust/${build_type}/${arch_abi}"
output_dir="${working_dir}"/libs/"${arch_abi}"
rust_source_root="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

echo "[RustLibBuilder] working_dir = ${working_dir}"
echo "[RustLibBuilder] build_dir = ${build_dir}"
echo "[RustLibBuilder] output_dir = ${output_dir}"
echo "[RustLibBuilder] rust_source_root = ${rust_source_root}"


mkdir -p "$build_dir"
mkdir -p "$output_dir"

cd "${rust_source_root}"

gcc_toolchain="${ndk_dir}/llvm"
sysroot="${ndk_dir}/sysroot"
linker="${gcc_toolchain}/bin/clang"

echo "[RustLibBuilder] gcc_toolchain = $gcc_toolchain"
echo "[RustLibBuilder] sysroot = $sysroot"
echo "[RustLibBuilder] linker = $linker"

rustflags="-C linker=\"${linker}\" -C link-args=--gcc-toolchain=\"${gcc_toolchain}\" --sysroot=\"${sysroot}\""
echo "[RustLibBuilder] CARGO_BUILD_RUSTFLAGS = ${rustflags}"

if [[ "${build_type}" = "Release" ]]; then
    CARGO_BUILD_RUSTFLAGS="${rustflags}" \
    cargo +nightly build \
      -Z unstable-options --release --lib \
      --target-dir "$build_dir" \
      --out-dir "$output_dir"   \
      -Zbuild-std=panic_abort,std \
      --target aarch64-linux-ohos.json
else
    CARGO_BUILD_RUSTFLAGS="${rustflags}" \
    cargo +nightly build \
      -Z unstable-options --lib \
      --target-dir "$build_dir" \
      --out-dir "$output_dir"   \
      -Zbuild-std=panic_abort,std \
      --target aarch64-linux-ohos.json
fi
