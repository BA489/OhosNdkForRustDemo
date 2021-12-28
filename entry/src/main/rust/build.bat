
@echo off

set argC=0
for %%x in (%*) do (
    set /A argC+=1
)

if %argC% NEQ 3 (
    echo Illegal number of parameters
    echo Usage: $0 ndk_dir build_type arch_abi
    exit /b 1
)

set ndk_dir=%1
set build_type=%2
set arch_abi=%3

echo [RustLibBuilder] ndk_dir = %ndk_dir%
echo [RustLibBuilder] build_type = %build_type%
echo [RustLibBuilder] arch_abi = %arch_abi%

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

set "gcc_toolchain=%ndk_dir%/llvm"
set "sysroot=%ndk_dir%/sysroot"
set "linker=%gcc_toolchain%/bin/clang.exe"
echo [RustLibBuilder] gcc_toolchain = %gcc_toolchain%
echo [RustLibBuilder] sysroot = %sysroot%
echo [RustLibBuilder] linker = %linker%

set "CARGO_BUILD_OLD_RUSTFLAGS=%CARGO_BUILD_RUSTFLAGS%"
set "CARGO_BUILD_RUSTFLAGS=-C linker=%linker% -C link-arg=--gcc-toolchain=%gcc_toolchain% -C link-arg=--sysroot=%sysroot%"

echo [RustLibBuilder] CARGO_BUILD_RUSTFLAGS = %CARGO_BUILD_RUSTFLAGS%

if "%build_type%" == "Release" (
    cargo +nightly build ^
      -Z unstable-options --release --lib ^
      --target-dir "%build_dir%" ^
      --out-dir "%output_dir%"   ^
      -Zbuild-std=panic_abort,std ^
      --target aarch64-linux-ohos.json
) else (
    cargo +nightly build ^
      -Z unstable-options --lib ^
      --target-dir "%build_dir%" ^
      --out-dir "%output_dir%"   ^
      -Zbuild-std=panic_abort,std ^
      --target aarch64-linux-ohos.json
)

set "CARGO_BUILD_RUSTFLAGS=%CARGO_BUILD_OLD_RUSTFLAGS%"

popd