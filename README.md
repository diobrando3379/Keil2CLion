# Keil2CLion

一键把 Keil5 的 STM32 工程转成 CLion + `arm-none-eabi-gcc` 工程，调好后还能一键转回 Keil。

转换时不改源码，也不用手动写 `CMakeLists.txt`、链接脚本和 GCC 启动文件。生成的 CLion 工程在 Windows 和 Mac 上都能编译。

## 功能

- **Keil → CLion：** 读取 `.uvprojx`，生成 CMake 工程。
- **自动处理 GCC 兼容问题：**
  - 把 Keil 启动文件转成 GCC 语法，保留向量表和栈、堆大小。
  - 根据 Keil 的内存设置生成链接脚本。
  - 修复 `core_cm3.c` 在 GCC 下的 STREX 汇编问题。
  - 把 `printf` 接到工程里的 `fputc`。
- **CLion → Keil：** 把新增或移除的文件、宏定义和头文件路径写回 Keil 工程，再删除 CLion 文件。
- **改动很小：** 没有差异时不写入 Keil 工程文件；有差异时只改相关内容，并先备份。

## 脚本

| 文件 | 平台 | 作用 |
|---|---|---|
| `Keil2CLion.bat` | Windows | Keil → CLion |
| `Keil2CLion.command` | Mac | Keil → CLion |
| `CLion2Keil.bat` | Windows | CLion → Keil |
| `clear.cmd` | Windows | 清理编译产物 |
| `clear.command` | Mac | 清理编译产物 |

Windows 脚本基于系统自带的 PowerShell，Mac 脚本基于 Perl，都不用另外安装 Python。

## 快速开始

### 1. 安装编译器

Windows：

```bash
winget install --id Arm.GnuArmEmbeddedToolchain --exact
```

Mac：

```bash
brew install --cask gcc-arm-embedded
```

### 2. 转成 CLion 工程

- **Windows：** 把工程文件夹拖到 `Keil2CLion.bat` 上。
- **Mac：** 运行下面的命令。

```bash
sh Keil2CLion.command /path/to/工程文件夹
```

### 3. 编译

用 CLion 打开工程文件夹，直接 Build。输出的 `.elf`、`.hex` 和 `.map` 在 `cmake-build-debug` 里。

### 4. 转回 Keil

1. 关闭 Keil，并在 CLion 里关闭这个工程。
2. 在 Windows 上把工程文件夹拖到 `CLion2Keil.bat` 上。
3. 用 Keil 打开工程编译。

## 注意事项

- **转换前的清理：** `Keil2CLion` 会先删除 Keil 的中间文件，包括 `DebugConfig` 和 `*.uvguix.*`，也就是 Keil 的调试配置和窗口布局。回到 Keil 后第一次要全部重新编译。
- **语法差异：** `0b101`、`typeof`、语句表达式 `({ ... })` 能用 GCC 编译，但 Keil 的 ARMCC 会报错。
- **文件名：** 用英文。ARMCC 打不开中文文件名。
- **串口 `printf`：** 继续写 `fputc`，不要改成 `_write`。
- **型号宏：** Keil 芯片包自动加的宏（如 `STM32F10X_MD`）会根据启动文件名推导，规则见[使用说明](使用说明.md#型号宏)。推导不出时脚本会提示，在 Keil 的 Define 框里手动加上即可。
- **编译结果不同：** 两个编译器生成的程序不一样，时序敏感的功能要分别验证。
- **`cmake/` 里的文件都是生成的：** 手动修改不会同步回 Keil，转回时还会被删除。

## 限制

- 只支持 Cortex-M 内核，工程里要有 ARM 语法的启动文件（`.s`）。由 Keil RTE 管理的启动文件读不到。
- 主要面向 ARM Compiler 5 工程。AC6 工程只做了基本适配，没有测试过。
- 不支持 C++ 源文件，也不能使用 Keil 编译好的 `.lib`、`.o`。
- 只生成一段 Flash 和一段 RAM，Keil 里的 IRAM2、CCM 等额外内存不会写进链接脚本。
- `CLion2Keil` 目前只有 Windows 版。
- 没有配置 CLion 里的烧录和调试。

## 测试情况

已测试：

- 用 15 个真实的 STM32F103 Keil 工程测试，转换后都能用 `arm-none-eabi-gcc` 14.2 和 CLion 自带的 CMake、Ninja 编译。
- 用 Keil 芯片包里的 CMSIS 启动文件，测试了 Cortex-M0、M0+、M1、M3、M4 和 M7 的转换和编译，包括 M4、M7 的硬件浮点。这些测试工程是临时搭的，只验证能编译。
- 没有增删文件时，转过去再转回来，工程和原来逐字节相同。
- 新增文件和文件夹后转回 Keil，用 ARMCC 编译 0 错误 0 警告，Keil 界面也能显示新文件。

还没验证：

- 没有在真实的 Mac 上运行过。Mac 脚本是在 WSL 的 Linux 上测试的，生成结果和 bat 逐字节一致。
- 除 STM32F103 外，没有用其他系列的真实工程测试过，比如 CubeMX 生成的 F4、H7 工程。
- GCC 版本还没有在 CLion 界面里编译过。
- GCC 编译的程序还没有上板运行过。

## 详细文档

完整说明见 [使用说明.md](使用说明.md)，包括同步范围、编译器路径、换电脑时的处理等。
