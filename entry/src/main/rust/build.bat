
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

set "ndk_dir=%1"
set "build_type=%2"
set "arch_abi=%3"

echo [RustLibBuilder] ndk_dir = %ndk_dir%
echo [RustLibBuilder] build_type = %build_type%
echo [RustLibBuilder] arch_abi = %arch_abi%

set "working_dir=%cd%"
set "build_dir=%working_dir%\.rust\%arch_abi%"
set "output_dir=%working_dir%\libs\%arch_abi%"
set "rust_source_root=%~dp0"

echo [RustLibBuilder] working_dir = %working_dir%
echo [RustLibBuilder] build_dir = %build_dir%
echo [RustLibBuilder] output_dir = %output_dir%
echo [RustLibBuilder] rust_source_root = %rust_source_root%

set "tool_build_dir=%working_dir%\.rust\host"
set "tool_output_dir=%working_dir%\bin"
set "tool_build_script=%rust_source_root%\scripts\make_linker_wrapper.bat"

echo [RustLibBuilder] tool_build_script = %tool_build_script%
echo [RustLibBuilder] tool_build_dir = %tool_build_dir%
echo [RustLibBuilder] tool_output_dir = %tool_output_dir%

echo [RustLibBuilder] Start build linker_wrapper

if not exist "%tool_output_dir%" (
    mkdir "%tool_output_dir%"
)

call "%tool_build_script%" "%tool_build_dir%" "%tool_output_dir%"
echo [RustLibBuilder] linker_wrapper built succeed.

if not exist "%build_dir%" (
    mkdir "%build_dir%"
)

if not exist "%output_dir%" (
    mkdir "%output_dir%"
)

pushd .
cd "%rust_source_root%"

set "gcc_toolchain=%ndk_dir%\llvm"
set "sysroot=%ndk_dir%\sysroot"
set "linker=%gcc_toolchain%\bin\clang.exe"
set "linker_wrapper=%tool_output_dir%\linker_wrapper.exe"

echo [RustLibBuilder] gcc_toolchain = %gcc_toolchain%
echo [RustLibBuilder] sysroot = %sysroot%
echo [RustLibBuilder] linker = %linker%

set "CARGO_BUILD_OLD_RUSTFLAGS=%CARGO_BUILD_RUSTFLAGS%"
set "OLD_C_LINKER=%C_LINKER%"

REM set "CARGO_BUILD_RUSTFLAGS=-Z print-link-args -C linker=%linker_wrapper% -C link-arg=--gcc-toolchain=%gcc_toolchain% -C link-arg=--sysroot=%sysroot%"
set "CARGO_BUILD_RUSTFLAGS=-C linker=%linker_wrapper% -C link-arg=--gcc-toolchain=%gcc_toolchain% -C link-arg=--sysroot=%sysroot%"
REM The %linker_wrapper% will be called by rustc which is called by the following cargo command.
REM  %linker_wrapper% requires an environment variable named C_LINKER (which we point to the actual linker) be defined.
set "C_LINKER=%linker%"

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
set "C_LINKER=%OLD_C_LINKER%"

popd