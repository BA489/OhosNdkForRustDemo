@echo off

SETLOCAL

set "target_dir=%1"
set "output_dir=%2"

echo [RustToolBuilder] target_dir = %target_dir%
echo [RustToolBuilder] output_dir = %output_dir%

pushd .

set "script_dir=%~dp0"
cd "%script_dir%\..\..\tool"
set "tool_src_dir=%CD%"

echo [RustToolBuilder] script_dir = %script_dir%
echo [RustToolBuilder] tool_src_dir = %tool_src_dir%

cargo +nightly build -Z unstable-options --release --target-dir "%target_dir%" --out-dir "%output_dir%"

popd

echo [RustToolBuilder] Return to %CD%

ENDLOCAL
