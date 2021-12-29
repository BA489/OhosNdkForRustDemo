#!/usr/bin/env bash

args=()
for element in "$@"; do 
    if [[ "${element}" != "-llog" ]]; then 
        args+=("${element}")
    fi
done

echo "$C_LINKER \\"
for element in "${args[@]::${#args[@]}-1}"; do 
    echo "    $element \\"
done
echo "    ${args[${#args[@]}-1]}"

"$C_LINKER" "${args[@]}"
