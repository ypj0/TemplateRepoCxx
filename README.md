# C++20 工程模板

使用 CMake 管理公共库、主程序、测试和示例，使用 clangd 提供代码补全、
诊断和格式化。没有第三方运行依赖，也不需要 Git 即可配置、构建和统计代码。

## 环境要求

- CMake 3.21 或更高版本。
- 支持 C++20 的编译器，已验证 GCC 13 和 Clang 18。
- Ninja（预设使用 Ninja；手动配置可选择其他生成器）。
- clangd、clang-format、clang-tidy，推荐使用 LLVM 18 或更新版本。
- VS Code 可选，安装推荐的 clangd、CMake Tools 和 Microsoft C/C++ 扩展。
- 默认调试器为 GDB，需要安装并确保 `gdb` 在 PATH 中。
- cloc 可选，用于统计源码行数。

clangd 是语言服务器，不要求构建时必须使用 Clang 编译器。

## 快速开始

复制模板后，将项目根目录命名为自己的项目名，然后执行：

```bash
bash init_project.sh
```

脚本自动使用所在项目根目录的名称，同步修改 CMake 项目名和目标、C++ 命名空间、
公共头文件目录、构建选项、VS Code 调试路径以及文档中的名称。需要 Python 3。
目录名必须以英文字母开头，只包含英文字母、数字和下划线，不能是 C++ 关键字或包含双下划线。
例如目录名 `hello` 会生成 `include/hello/`、`hello::core` 和 `hello_app`。
可以从任意工作目录调用脚本；再次更改项目目录名后，也可以重新执行。

名称变化或发现复制过来的旧构建缓存时，脚本会直接删除 `build/`，不生成备份，
然后由下方命令重新生成构建目录。
同名且路径未变时重复运行不会改动有效的构建目录。复制模板时建议排除构建目录。

在项目根目录执行：

```bash
./build.sh
```

一条命令完成 Debug 配置和编译；首次使用也适用。构建为增量构建，
任一步失败都会停止。使用 `./build.sh release` 完成 Release 配置和编译。
脚本不会运行测试或程序，需要时自行执行 `ctest --preset debug` 或相应可执行文件。
脚本也支持从其他目录通过完整路径调用。

对应的手动命令为：

```bash
cmake --preset debug
cmake --build --preset debug --parallel
```

需要时手动测试和运行：

```bash
ctest --preset debug
./build/debug/app/my_project_app C++20
```

程序输出 `Hello, C++20!`。不传参数时输出 `Hello, world!`。

Release 构建与测试：

```bash
cmake --preset release
cmake --build --preset release --parallel
ctest --preset release
```

Debug 预设启用测试和示例；Release 启用测试、关闭示例。
测试使用返回码检查结果，在 Release 下也有效。
Windows 可执行文件带 `.exe` 后缀。

只构建一个目标：

```bash
cmake --build --preset debug --target my_project_app
```

## 工程结构与扩展

```text
include/my_project/   公共头文件
src/                  公共库实现，无需 main()
app/                  主程序入口
test/                 CTest 测试程序
example/              可选示例程序
build/debug/          Debug 构建产物和编译数据库
build/release/        Release 构建产物
```

- `my_project_core` 是静态库，其他目标通过别名 `my_project::core` 链接它。
- `my_project_app` 是主程序；公共头文件路径和 C++20 要求通过库目标传递。
- `src/` 和 `app/` 自动递归收集 `.cpp`、`.cc`、`.cxx`：前者合并为公共库，
  后者合并为主程序。新增或删除源码后直接构建，无需手动维护源文件列表。
  `src/` 不应包含 `main()`，`app/` 中所有源码合计只能有一个 `main()`。
- `test/` 和 `example/` 同样递归扫描，每个源文件生成一个独立程序，
  因此每个文件都需要自己的 `main()`。测试自动注册到 CTest。
  测试名包含相对路径，目标名包含路径摘要，支持子目录中的同名文件。
  这些目录中的共享辅助代码可放在头文件中；需要多源文件测试目标时再调整对应 CMake 配置。
- 自动发现使用 `CONFIGURE_DEPENDS`，已验证 Ninja；首次仍需执行配置命令。
  新文件在下一次构建时加入编译数据库，只有运行 `ctest` 不会触发文件扫描。
- 依赖通过 `find_package` 查找，再用 `target_link_libraries` 链接到实际使用它的目标。
  公共接口依赖使用 `PUBLIC`，实现细节依赖使用 `PRIVATE`。
- 修改项目名时，重命名项目根目录并运行 `bash init_project.sh`，同步更新相关配置。

关闭测试和示例的独立构建：

```bash
cmake -S . -B build/minimal -G Ninja \
  -DCMAKE_BUILD_TYPE=Release \
  -DBUILD_TESTING=OFF -DMY_PROJECT_BUILD_EXAMPLES=OFF
cmake --build build/minimal --parallel
```

默认使用系统编译器。指定 Clang 时应使用独立构建目录，例如：

```bash
cmake -S . -B build/clang -G Ninja -DCMAKE_CXX_COMPILER=clang++-18
cmake --build build/clang --parallel
```

不要在同一个已配置目录中直接切换编译器。
模板提供应用开发的基础结构；安装、发布打包和外部依赖管理需要按产品需求补充。

## clangd 与 VS Code

1. 安装 `.vscode/extensions.json` 推荐的扩展，并确保 `clangd` 在 PATH 中。
2. 首次打开项目时选择 `debug` 配置预设，或先运行 `cmake --preset debug`。
3. `.clangd` 固定读取 `build/debug/compile_commands.json`，从中获取 C++20、
   宏定义和头文件路径。切换 Release 构建不会改变编辑器使用的 Debug 配置。
4. 若要分析其他构建配置，修改 `.clangd` 的 `CompilationDatabase`，然后重启 clangd。
5. `Ctrl+Shift+B` 配置并构建 Debug；F5 使用 GDB 调试主程序，调试前自动构建。
   通过任务 `CMake: test debug` 执行测试。

Microsoft C/C++ 扩展提供 GDB 调试功能；已禁用其 IntelliSense，避免与 clangd 重复诊断。
代码保存时使用 clangd 格式化。调试参数可在 `.vscode/launch.json` 的 `args` 中设置。
若修改主程序目标名，也需要同步修改其中的 `program` 路径。

## 格式化与静态检查

```bash
bash format_count.sh
clang-tidy -p build/debug src/greeting.cpp app/main.cpp
clangd --check=app/main.cpp
```

格式化脚本会直接修改源码。安装 cloc 后会额外统计代码行数，未安装则跳过统计。
静态检查使用 `.clang-tidy`；clangd 也启用了 clang-tidy 诊断，普通构建不强制运行它。
