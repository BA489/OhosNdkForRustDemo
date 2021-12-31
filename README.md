最近迷上了 rust 语言，心血来潮，想尝试一下是否能够在鸿蒙中运行 rust 编写的程序。 鸿蒙NDK 已经支持了 C/C++ 编写库，并集成到 app 中, 而 rust 可以编译出 c 兼容的接口，而因此原则上来讲，在鸿蒙中运行 rust 编写的程序在原理上是可行的。

鸿蒙号称可以支持多种设备，但是这个项目只是针对手机，而且是比较新的手机（准确地讲是基于 aarch64 的手机）。NDK 编译到不同设备，需要不同的交叉编译器（或者编译目标），本项目只对 鸿蒙 NDK 中的 aarch64-linux-ohos 编译目标进行了尝试。

但在实施上还是有一些困难需要克服。下面就简单介绍这个项目实现的思路。



## 依赖

- DevEco Studio 3.0 Beta1，Windows 和 macOS 均可。其他版本可能也行，但是没有测试。

  - HarmonyOS Legacy SDK (API version 7)
    - Java
    - JS（这个项目可能不需要，默认安装的）
    - Native

- rust

  - 建议使用官方推荐的[rustup](https://rustup.rs/)方式安装

  - 本项目依赖 nightly 工具链以及 rust 源码：

    ```bash 
    rustup toolchain add nightly
    rustup component add rust-src
    ```



## 实现方法

### 方法一

（方法一仅用于想法验证，无特殊情况，请直接移步方法二，依赖更少，构建、运行更方便）

为了快速验证可以在鸿蒙手机中调用 rust 编写的库，考虑到安卓与鸿蒙在手机系统上的相似性，猜想其编译出的二进制文件是兼容的。因如果该猜想成立，先借用 android 的工具链编译生成动态连接库，拷贝到鸿蒙中使用。在 android 中编译 rust 代码目前已经得到了比较好的的支持，例如[rust-android-gradle](https://github.com/mozilla/rust-android-gradle)插件项目。但在DevEco Studio中不能直接使用该插件。

为了实现一键构建运行，我使用了 [corrosion](https://github.com/corrosion-rs/corrosion) 项目，它可以将 rust 的编译过程集成到 camke 中，然后在 gradle 中调用 cmake 进行构建。整个构建过程生成的动态链接库会被自动的打包。要运行这个版本，需要检出代码库中的第一个提交：

```bash
git checkout a88f485b1fb21f7115fa7024c1eecef3ae9e6fa2
```

该方法依赖额外的 Android 开发工具链。并且通过验证可以运行示例的 rust 代码，但毕竟鸿蒙提供的NDK与 Android NDK 有所区别，不能完全保证编译出来的库可以完全兼容运行。

#### 额外的依赖

 -  [corrosion](https://github.com/corrosion-rs/corrosion) 
 - Android Studio
   - NDK 21.4.7075529 或 22.1.7171670
     - 版本 23.1.7779620 没有成功 

### 方法二

最新版本的代码，可以一键进行构建、运行。下面简单介绍一下实现这个过程的一些技术点。

方法一验证了鸿蒙手机的确可以加载 rust 编译出来的动态连接库（尽管是借用的 android 的交叉编译器编译出来的），鸿蒙的 NDK 也提供了交叉编译器，一个自然的想法当然就是直接使用鸿蒙自带的交叉工具链。

#### Rust 自定义编译目标

要将 rust 代码交叉编译到鸿蒙，需要自定义编译目标。尽管原理上讲，我们只需要交叉编译工具链中的连接器，来讲 rustc 编译成的目标文件连接成为我们需要的动态链接库，但这并不意味着，将默认的连接器修改为交叉编译器的连接器就万事大吉了。由于rust 的 jni crate 依赖 std，对鸿蒙系统，无官方预编译的 std crate，因此需要我们自己编译。对非 rust 官方内建的编译目标(target), 对 std 及其依赖的 crate 进行交叉编译并不是容易的事情。这需要一个目标规格文件，用于描述目标系统的各种属性。即使能够很好对目标系统进行描述，也很可能不能完成对 std 的完整的交叉编译，因为一些底层的库，例如 libc 涉及 FFI，需要对一些接口代码进行适配，才能完整保证兼容。这里使用了一种风险的方法，在本节末尾会再次提到。

我主要是参考[这篇](https://docs.rust-embedded.org/embedonomicon/custom-target.html)和[这篇](https://github.com/japaric/rust-cross)文档进行整个项目的交叉编译的。rust 项目的构建通常使用 cargo 工具，通过--target 参数指定编译的目标，不指定时，默认编译到本机默认的目标，例如我的 macOS 上默认编译到 `x86_64-apple-darwin`

```bash
$ rustc -vV | grep host
host: x86_64-apple-darwin
```

当我们要编译到 android 时，可以执行l类型这样的代码（实际上可能需要其他额外的配置，例如 android NDK 中 linker 的位置，该命令才能执行成功，这不是当前讨论的重点，先忽略）

```bash
cargo build --target aarch64-linux-android
```

由于鸿蒙暂未得到 rust 官方支持，因此并没有如`aarch64-linux-android` 和 `x86_64-apple-darwin` 这样的内建的编译目标可以直接使用。为了交叉编译到鸿蒙，需要自定义交叉编译的目标。一个编译目标可以通过一个 json 文件来描述，我们称这个 json 文件为目标系统的**规格**。创建一个目标的规格，推荐的方法是修改与目标系统相似的**内建目标的规格**。修改的方式是调整规格中的属性值，使它匹配目标系统的属性。鉴于鸿蒙手机系统与 android 系统的相似性，我们使用 `aarch64-linux-android` 这个内建目标来进行修改。内建目标的规格可以通过如下命令获取到：

```bash
$ rustc +nightly -Z unstable-options --print target-spec-json --target aarch64-linux-android
{
  "arch": "aarch64",
  "data-layout": "e-m:e-i8:8:32-i16:16:32-i64:64-i128:128-n32:64-S128",
  ...
  ...
  "target-pointer-width": "64"
}
```

为了获取鸿蒙 NDK 编译连接过程中的默认参数，我们可以在 DevEco Studio 创建一个 Native C++ 项目，在 Debug 模式下，编译后，会在`entry/debug/arm64-v8a/`目录下生成 `compile_commands.json`文件，我们可以中这个文件中找到编译 C++ 文件的默认命令行，从这个命令行中解析出需要的参数，添加到规格文件中的 `pre-link-args`和`post-link-args`中。另外，还需要添加 `linker`,`linker-flavor`等属性。`linker` 是我们要调用的连接器命令的名称，`linker-flavor`指定了连接器接受的参数的“风格”，是 cargo 为我们生成连接器参数形式时，需要的值。估计是因为连接器可接受的参数格式并没有个形式化的定义，因此使用“flavor(风格)”一词。`linker-flavor`可设置的值可参见[这里](https://doc.rust-lang.org/rustc/codegen-options/index.html#linker-flavor)。下面通过一个简单的例子，来说明`linker-flavor`参数的作用：当我们要连接到 `m` 库时，

- 如果 `linker-flavor` 设置为 `ld` 时，cargo 可能为我们生成连接器的参数为 `-lm`
- 如果 `linker-flavor` 设置为 `gcc` 时，cargo 可能为我们生成连接器的参数为 `-Wl,-lm`

##### 自定义目标规格文件中的潜在风险

一个潜在的风险，在这里需要说明，在规格文件中，我们保留了 `"os" = "android"`。经过尝试，修改为 linux 等其他值暂时都不行。当修改为 linux 时，会导致编译 libc crate 出错。这意味着，在编译 rust 中 的 libc crate 时，使用的 rust 端的源代码实际上是为 Android 中 libc 的量身定制的。如果 Android 中 libc 与鸿蒙的 libc 外部类型、数据、接口的定义一致，那么不会有问题，否则就会出现意想不到的错误。这涉及一些底层的东西，原理上要求 rust 端的定义与 c 端的定义(头文件中各个类型的定义)要一致，这样才能使得 rustc 编译的东西，能够与NDK提供的 libc.so 兼容，才能无缝地从 rust 调用c库。因为底层都是连接这个 c 库的 libc.so。目前rust 的 libc crate 并不支持鸿蒙。除非鸿蒙继续疯狂生长，达到 android 的水平，否则估计rust 官方也不会提供对鸿蒙的支持。或者华为支持 rust，为诸如 libc 这样的基础 crate 提交支持代码。由于该风险的存在，无法保证兼容性，这个项目可能永远只能作为一个示例，而不能用于真实生产场景中。

#### 构建脚本

我们为 rust 代码部分编写了一键式的构建脚本，并让 gradle 调用该构建脚本实现整个项目一键构建。另外，构建脚本还有一些重要的功能，例如，连接器的一些重要的参数，例如`--gcc-toolchain`和`--sysroot`并不适合放在规格文件中，特别是要在不同的系统上共享使用该规格文件的时候。因为它们涉及 NDK 安装的位置。不同的用户、不同的操作系统，安装位置很可能不同，硬编码到规格文件中，就不能很好的重用目标的规格文件了。通过构建脚本，NDK 的安装位置，可以以参数的形式，由 gradle 负责传入。在构建脚本中，可以自由地计算出基于 NDK 安装目录的各种需要的路径，并以环境变量的方式环境变量或参数的形式传递给 cargo，详见 rust 的构建脚本 `entry/src/main/rust/build.sh`或 `build.bat`。

##### 不支持的选项的处理方法

使用 `"os" = "android"`，cargo 在生成连接命令行时，会默认插入对 log 库的连接的选项 `-llog`, 在鸿蒙的 NDK 中，并没有` liblog.so` 文件 (对标的库文件是`hilog_ndk.z.so`?), 这会导致连接时报找不到库文件的错误。一个方法是创建到`hilog_ndk.z.so`的软连接，并命名为 `liblog.so`, 只要不使用 `liblog.so` 中定义的东西就好。但这样做需要用户自行对 NDK 目录进行修改，不能简单地克隆该仓库，直接就能够运行。

为了解决这个问题，我编写了一个连接器的封装程序，由它接受编译参数，过滤掉不支持的选项后，再传递给真实的连接器。这部分代码是一个小型的 rust 项目，见 `entry/src/main/tool`. 比较坑的是，在 Windows 下，由于命令行长度限制非常严格，而 cargo 生成的命令行通常都超长，传递给连接器命令行参数会自动转存到一个临时文件中，然后将这个临时文件以 [response file](https://llvm.org/docs/CommandLine.html#response-files) 的形式传递给连接器，导致 macOS 和 Windows 上处理命令行参数的方式有所不同。具体问题可见[这里](https://stackoverflow.com/questions/40727748/windows-clang-command-line-too-long)。本来以为 rust 开发的可以跨平台，结果 Windows 的奇怪处理逻辑，破坏了一致性，又一次被 Windows 恶心到了。

#### 其他坑

最后，我似乎规格文件的命名也会对cargo生成的连接命令产生影响，见[这里](https://github.com/rust-lang/wg-cargo-std-aware/issues/60)。我是在以 `aarch64-unknown-linux-gnu` 目标作为鸿蒙目标规格文件的基础时，偶然发现的。我现在的理解是，对自定义的目标，最好的命名方式是基础目标名字后再添加其他字段，例如，`aarch64-unknown-linux-gnu-ohos.json`, 或者在构建时，提供 [`CARGO_CFG_TARGET_*` 系列环境变量](https://doc.rust-lang.org/cargo/reference/environment-variables.html#environment-variables-cargo-sets-for-build-scripts)的值。由于从 ``aarch64-unknown-linux-gnu``开始创建鸿蒙target 的规格文件没有成功，可能是因为 libc 存在差异较大，最后出现连接错误，这里就不在详说了。



## References 
- https://github.com/mozilla/rust-android-gradle
- https://github.com/japaric/rust-cross
- https://github.com/corrosion-rs/corrosion
- https://doc.rust-lang.org/rustc/codegen-options/index.html#linker-flavor
- https://llvm.org/docs/CommandLine.html#response-files