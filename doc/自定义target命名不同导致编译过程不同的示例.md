前两个命令可以正常编译，只是到了连接阶段才因为缺失符号报错。后两个命令，在编译 std 时就报错了，还没有到连接阶段。

```bash
CARGO_BUILD_RUSTFLAGS="-C linker=/Users/cyc/Sources/LearnAndroid/OhosNdkDemo/entry/bin/linker_wrapper -C link-arg=--gcc-toolchain=/Users/cyc/Library/Huawei/sdk/native/3.0.0.0/llvm -C link-arg=--sysroot=/Users/cyc/Library/Huawei/sdk/native/3.0.0.0/sysroot" \
C_LINKER="/Users/cyc/Library/Huawei/sdk/native/3.0.0.0/llvm/bin/clang" \
cargo "+nightly" "build" "-Z" "unstable-options" "--lib" "-Zbuild-std=panic_abort,std" "--target" "aarch64-ohos-linux-gnu.json"
```

```bash
CARGO_BUILD_RUSTFLAGS="-C linker=/Users/cyc/Sources/LearnAndroid/OhosNdkDemo/entry/bin/linker_wrapper -C link-arg=--gcc-toolchain=/Users/cyc/Library/Huawei/sdk/native/3.0.0.0/llvm -C link-arg=--sysroot=/Users/cyc/Library/Huawei/sdk/native/3.0.0.0/sysroot" \
C_LINKER="/Users/cyc/Library/Huawei/sdk/native/3.0.0.0/llvm/bin/clang" \
cargo "+nightly" "build" "-Z" "unstable-options" "--lib" "-Zbuild-std=panic_abort,std" "--target" "aarch64-unknown-linux-gnu-ohos.json"
```

```bash
CARGO_BUILD_RUSTFLAGS="-C linker=/Users/cyc/Sources/LearnAndroid/OhosNdkDemo/entry/bin/linker_wrapper -C link-arg=--gcc-toolchain=/Users/cyc/Library/Huawei/sdk/native/3.0.0.0/llvm -C link-arg=--sysroot=/Users/cyc/Library/Huawei/sdk/native/3.0.0.0/sysroot" \
C_LINKER="/Users/cyc/Library/Huawei/sdk/native/3.0.0.0/llvm/bin/clang" \
cargo "+nightly" "build" "-Z" "unstable-options" "--lib" "-Zbuild-std=panic_abort,std" "--target" "aarch64-unknown-ohos-gnu.json"
```

```bash
CARGO_BUILD_RUSTFLAGS="-C linker=/Users/cyc/Sources/LearnAndroid/OhosNdkDemo/entry/bin/linker_wrapper -C link-arg=--gcc-toolchain=/Users/cyc/Library/Huawei/sdk/native/3.0.0.0/llvm -C link-arg=--sysroot=/Users/cyc/Library/Huawei/sdk/native/3.0.0.0/sysroot" \
C_LINKER="/Users/cyc/Library/Huawei/sdk/native/3.0.0.0/llvm/bin/clang" \
CARGO_CFG_TARGET_VENDOR=unknown \
CARGO_CFG_TARGET_OS=linux \
cargo "+nightly" "build" "-Z" "unstable-options" "--lib" "-Zbuild-std=panic_abort,std" "--target" "aarch64-unknown-ohos-gnu.json"
```

这四个命令使用的三个 target json 文件的内容完全一致（通过拷贝），如下：

```json
{
    "arch": "aarch64",
    "crt-static-respected": true,
    "data-layout": "e-m:e-i8:8:32-i16:16:32-i64:64-i128:128-n32:64-S128",
    "dynamic-linking": true,
    "env": "gnu",
    "executables": true,
    "features": "+neon,+fp-armv8",
    "panic-strategy": "abort",
    "has-rpath": true,
    "llvm-target": "aarch64-linux-ohos",
    "max-atomic-width": 128,
    "os": "linux",
    "position-independent-executables": true,
    "relro-level": "full",
    "supported-sanitizers": [
        "address",
        "cfi",
        "leak",
        "memory",
        "thread",
        "hwaddress"
      ],
    "target-family": [
        "unix"
    ],
    "target-mcount": "\u0001_mcount",
    "linker-flavor": "gcc",
    "linker": "clang",
    "target-pointer-width": "64",
    "pre-link-args": {
        "gcc": [
            "-Wno-error=unused-command-line-argument",
            "--target=aarch64-linux-ohos",
            "-fPIC",
            "-fdata-sections",
            "-ffunction-sections",
            "-funwind-tables",
            "-fstack-protector-strong",
            "-no-canonical-prefixes",
            "-fno-addrsig",
            "-Wa,--noexecstack",
            "-Wl,-z,noexecstack",
            "-Wformat",
            "-Werror=format-security",
            "-fno-limit-debug-info",
            "--rtlib=compiler-rt",
            "-fuse-ld=lld",
            "-Wl,--build-id=sha1",
            "-Wl,--warn-shared-textrel",
            "-Wl,--fatal-warnings",
            "-lunwind",
            "-Wl,--no-undefined",
            "-Qunused-arguments",
            "-Wl,--allow-multiple-definition"
        ]
    },
    "post-link-args": {
        "gcc": [
            "-Wl,--allow-multiple-definition",
            "-Wl,--start-group,-lhilog_ndk.z,-lm,-lc,--end-group"
        ]
    }
}
```