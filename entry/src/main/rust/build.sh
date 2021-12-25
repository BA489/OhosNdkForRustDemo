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
corrosion_dir="/usr/local/lib/cmake/Corrosion"
android_ndk="/Users/cyc/Library/Android/sdk/ndk/21.4.7075529"

working_dir=$PWD
build_dir="${working_dir}"/.rust/"${build_type}/${arch_abi}"
output_dir="${working_dir}"/libs/"${arch_abi}"
rust_source_root="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

echo "[RustLibBuilder] working_dir = ${working_dir}"
echo "[RustLibBuilder] cmake_info = $(cmake --version | head -n 1)"
echo "[RustLibBuilder] build_dir = ${build_dir}"
echo "[RustLibBuilder] output_dir = ${output_dir}"
echo "[RustLibBuilder] rust_source_root = ${rust_source_root}"
echo "[RustLibBuilder] corrosion_dir = ${corrosion_dir}"
echo "[RustLibBuilder] android_ndk = ${android_ndk}"


mkdir -p "$build_dir"
mkdir -p "$output_dir"

cd "$build_dir"
cmake -DCMAKE_BUILD_TYPE="${build_type}" \
      -DCorrosion_DIR="${corrosion_dir}" \
      -DCMAKE_SYSTEM_NAME=Android \
      -DCMAKE_ANDROID_NDK="${android_ndk}" \
      -DCMAKE_ANDROID_ARCH_ABI="${arch_abi}" \
      "${rust_source_root}"
make

for file in $(ls *.so); do
    dest_file="${output_dir}/$file"
    if [[ -f "${dest_file}" ]]; then
        if [[ "${file}" -nt "${dest_file}" ]]; then
            echo cp "${file}" "${dest_file}"
            cp "${file}" "${dest_file}"
        fi
    else
        echo cp "${file}" "${dest_file}"
        cp "${file}" "${dest_file}"
    fi
done
