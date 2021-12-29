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
build_dir="${working_dir}/.rust/${arch_abi}"
output_dir="${working_dir}"/libs/"${arch_abi}"
rust_source_root="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

echo "[RustLibBuilder] working_dir = ${working_dir}"
echo "[RustLibBuilder] build_dir = ${build_dir}"
echo "[RustLibBuilder] output_dir = ${output_dir}"
echo "[RustLibBuilder] rust_source_root = ${rust_source_root}"

tool_build_dir="${working_dir}/.rust/host"
tool_output_dir="${working_dir}/bin"
tool_build_script="${rust_source_root}/scripts/make_linker_wrapper.sh"

echo "[RustLibBuilder] tool_build_script = ${tool_build_script}"
echo "[RustLibBuilder] tool_build_dir = ${tool_build_dir}"
echo "[RustLibBuilder] tool_output_dir = ${tool_output_dir}"

echo "[RustLibBuilder] Start build linker_wrapper"
chmod u+x "${tool_build_script}"
mkdir -p "${tool_output_dir}"
"${tool_build_script}" "${tool_build_dir}" "${tool_output_dir}"
echo "[RustLibBuilder] linker_wrapper built succeed. "

mkdir -p "$build_dir"
mkdir -p "$output_dir"

cd "${rust_source_root}"

gcc_toolchain="${ndk_dir}/llvm"
sysroot="${ndk_dir}/sysroot"
linker="${gcc_toolchain}/bin/clang"
# linker_wrapper="${rust_source_root}/scripts/linker_wrapper.sh"
linker_wrapper="${tool_output_dir}/linker_wrapper"

echo "[RustLibBuilder] gcc_toolchain = $gcc_toolchain"
echo "[RustLibBuilder] sysroot = $sysroot"
echo "[RustLibBuilder] linker = $linker"

# rustflags="-Z print-link-args -C linker=${linker_wrapper} -C link-arg=--gcc-toolchain=${gcc_toolchain} -C link-arg=--sysroot=${sysroot}"
rustflags="-C linker=${linker_wrapper} -C link-arg=--gcc-toolchain=${gcc_toolchain} -C link-arg=--sysroot=${sysroot}"
echo "[RustLibBuilder] CARGO_BUILD_RUSTFLAGS = ${rustflags}"

args=(
    "+nightly" 
    "build"
    "-Z" "unstable-options"
    "--lib"
    "--target-dir" "$build_dir"
    "--out-dir" "$output_dir"
    "-Zbuild-std=panic_abort,std"
    "--target" "aarch64-linux-ohos.json"
)

if [[ "${build_type}" = "Release" ]]; then
    args+=("--release")
fi

echo "[RustLibBuilder] Running command: " CARGO_BUILD_RUSTFLAGS=\""${rustflags}"\" C_LINKER=\""$linker"\" cargo "${args[@]}"
CARGO_BUILD_RUSTFLAGS="${rustflags}" C_LINKER="$linker" cargo "${args[@]}"
