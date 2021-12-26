
@echo off

set argC=0
for %%x in (%*) do (
    set /A argC+=1
)

if %argC% NEQ 2 (
    echo Illegal number of parameters
    echo Usage: $0 build_type arch_abi
    exit /b 1
)

set build_type=%1
set arch_abi=%2

echo %build_type%
echo %arch_abi%

set "working_dir=%cd%"
set "build_dir=%working_dir%/.rust/%build_type%/%arch_abi%"
set "output_dir=%working_dir%/libs/%arch_abi%"
set "rust_source_root=%~dp0"

echo [RustLibBuilder] working_dir = %working_dir%
echo [RustLibBuilder] build_dir = %build_dir%
echo [RustLibBuilder] output_dir = %output_dir%
echo [RustLibBuilder] rust_source_root = %rust_source_root%

if not exist "%build_dir%" (
    mkdir "%build_dir%"
)

if not exist "%output_dir%" (
    mkdir "%output_dir%"
)

pushd .
cd "%rust_source_root%"

if "%build_type%" == "Release" (
    cargo +nightly build ^
      -Z unstable-options --release --lib ^
      --target-dir "%build_dir%" ^
      --out-dir "%output_dir%"   ^
      -Zbuild-std=panic_abort,std ^
      --target aarch64-linux-ohos-win.json
) else (
    cargo +nightly build ^
      -Z unstable-options --lib ^
      --target-dir "%build_dir%" ^
      --out-dir "%output_dir%"   ^
      -Zbuild-std=panic_abort,std ^
      --target aarch64-linux-ohos-win.json
)

popd