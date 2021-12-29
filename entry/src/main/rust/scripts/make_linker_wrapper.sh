#!/usr/bin/env bash
set -e
set -o pipefail

target_dir="$1"
output_dir="$2"

echo "[RustToolBuilder] target_dir = ${target_dir}"
echo "[RustToolBuilder] output_dir = ${output_dir}"

script_dir="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
tool_src_dir="$( cd "${script_dir}/../../tool" &> /dev/null && pwd )"

echo "[RustToolBuilder] script_dir = ${script_dir}"
echo "[RustToolBuilder] tool_src_dir = ${tool_src_dir}"

cd "${tool_src_dir}"
cargo +nightly build -Z unstable-options --release --target-dir "${target_dir}" --out-dir "${output_dir}"
