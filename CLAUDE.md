# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## 项目概述

CapsKeyPlus 是基于 **AutoHotkey v1.1** 的键盘增强工具。入口脚本 `CapsKeyPlus.ahk`，核心逻辑在 `lib/`，用户自定义函数在 `userAHK/main.ahk`，配置在 `CapsKeyPlusSettings.ini`。

## 运行与校验

- 运行源码：需 AutoHotkey v1.1（本机路径 `D:\Program Files\AutoHotkey\v1.1.37.02\AutoHotkeyU64.exe`）。直接运行 `CapsKeyPlus.ahk` 即可，脚本会**自我提权到管理员**（弹 UAC）。
- 重载：脚本内按 `CapsLock+F5`，或托盘菜单"重启"。
- **语法/加载校验**：不要直接运行主脚本做测试（会弹 UAC 并注册全局热键）。正确做法：
  1. 在项目根目录创建临时测试脚本，`#NoEnv` + `ExitApp` 放最前面（只解析不执行），然后**完整复制 `CapsKeyPlus.ahk` 第 76–108 行的 include 块**（`#Include %A_ScriptDir%\lib` + 各 `lib_*.ahk` + `..\language\*.ahk`）。
  2. 从 Git Bash 运行，注意 MSYS 会把 `/ErrorStdOut` 参数改写为路径，需禁用转换：
     ```bash
     export MSYS2_ARG_CONV_EXCL="*"
     ".../AutoHotkeyU64.exe" /ErrorStdOut "D:\\...\\__check.ahk"
     ```
  3. exit 0 表示通过；AHK 在**加载期就会校验函数存在性**，所以 include 块必须完整，否则会报 "Call to nonexistent function"。

## 编码（重要，改文件前必读）

- `CapsKeyPlus.ahk`：**GBK/ANSI，无 BOM**。Edit/Write 工具会拒绝处理，必须用 shell 或 Python 以 GBK 读写，切勿转成 UTF-8（会导致中文乱码且与现有运行环境不一致）。
- `lib/*.ahk` 与 `language/*.ahk`：**UTF-8 with BOM**。用 Python 编辑时以 `encoding='utf-8-sig'` 读、写回，保留 BOM 和原行尾。
- 判断编码：`head -c 3 文件 | xxd`，`efbb bf` 是 UTF-8 BOM，`23 53 69`（`#Si`）是无 BOM 的 ANSI/GBK。

## 架构要点

### 启动流程

1. `CapsKeyPlus.ahk` 开头自我提权：非 `/restart` 参数时 `Run *RunAs` 以管理员重启。
2. `#Include %A_ScriptDir%\lib` 是**目录 include，只把 lib 目录加入搜索路径**；真正加载文件的是后面逐行的 `#include lib_xxx.ahk`。随后 include `..\language\` 的三个语言文件和 `..\userAHK`、`#include *i main.ahk`。
3. `lib/lib_init.ahk` 用 `SetTimer, initAll, -400` 延迟初始化：`Suspend, On` 挂起热键、按语言 `gosub language_*`、`gosub settingsInit`、`bindWinsInit` 等。
4. `lib/lib_settings.ahk` 的 `settingsInit:` 构建全局 `CLSets` 对象（`CLSets.global.*`），`iniSections` 固定为 `["Global","QSearch","QRun","QWeb","TabHotString","QStyle","TTranslate","Keys"]`。

### 热键分发

- `#If CapsLock` 段定义 CapsLock 按住时的组合键，统一调用 `runFunc(keyset["caps_" . A_ThisHotkey])`；`<!a` 等 LAlt 组合对应 `keyset.caps_lalt_*`，`#1` 等 Win 组合对应 `keyset.caps_win_*`。
- `keyset` 由 `lib_keysSet.ahk` 从 settings.ini 的 `[Keys]` 构建，形如 `caps_f7=keyFunc_example1` 的配置被映射为函数调用。
- `runFunc(str)`（`lib_functions.ahk`）把 `"funcName(arg1,arg2)"` 字符串按 CSV 拆参后动态调用；**用户自定义函数必须以 `keyFunc_` 开头**，写在 `userAHK/main.ahk`。
- `Capslock::` 单独处理：按下时设 `ctrlZ/CapsLock2/CapsLock:=1` 并 `KeyWait`；300ms 定时器 `setCapsLock2` 判定是"单独按 CapsLock 切换大小写"还是"CapsKeyPlus 组合键"。

### 剪贴板系统

- 全局变量：`sClipboardAll`（系统剪贴板）、`cClipboardAll`（CapsLock+C 槽）、`caClipboardAll`（CapsLock+Alt+C 槽）、`whichClipboardNow`（0=系统/1=c槽/2=ca槽）、`allowRunOnClipboardChange`。
- `OnClipboardChange:` 在非 CapsLock 且 `CLsets.global.allowClipboard != "0"` 时调用 `clipSaver("s")` 保存系统剪贴板并置 `whichClipboardNow:=0`；`allowRunOnClipboardChange:=false` 防止回写 `Clipboard:=sClipboardAll` 时递归触发。
- `$^v::`（受 `#If CLsets.global.allowClipboard != "0"` 保护）拦截 Ctrl+V → `keyFunc_pasteSystem()`：非系统槽时先恢复 `sClipboardAll` 再 `SendInput ^{v}`。
- **Excel 崩溃防护**：`clipSaver(clipX)` 在 `WinActive("ahk_exe EXCEL.EXE")` 时直接 `return 0`（不读 `ClipboardAll`、不抢焦点），否则保存并 `return 1`。原因：Excel 复制后剪贴板是延迟渲染的，立即读取 + 切换窗口焦点会破坏 Excel 复制状态，粘贴时导致 Excel 崩溃。
- `keyFunc_paste_1/paste_2` 恢复 c/ca 槽时同样加 `!WinActive("ahk_exe EXCEL.EXE")` 守卫；`keyFunc_copy_1/cut_1/copy_2/cut_2` 在 Excel 下 `clipSaver` 返回 0 时把 `whichClipboardNow` 置 0（视为系统复制），避免槽位状态错乱。

### 新增：窗口绑定列表 & 帮助菜单

- 托盘菜单新增「窗口绑定信息」（`keyFunc_showWinBindList`，`lib_keysFunction.ahk`）和「帮助文档」（`showHelpGui`，`lib/lib_help.ahk`）。
- 默认热键 `CapsLock+F9` 绑定 `keyFunc_showWinBindList`（两个热键方案中均已设置）。
- `keyFunc_showWinBindList` 读取全局 `winsInfos`，用 ListView 展示按键 1~10 的绑定模式/程序名称/路径/窗口ID，双击行可激活对应窗口。
- `lib_help.ahk` 的 `showHelpGui` 左侧分类列表 + 右侧只读文档；文档内容来自语言文件的 `lang_help_*` 变量（中文完整版 / 英文简版）。
- 帮助文档内容源自官网 https://capslox.com/capslock-plus/ 的「功能说明」章节，中文版在 `language/Simplified_Chinese.ahk`，英文简版在 `language/English.ahk`。

## 常用函数速查

- `clipSaver(clipX)`：保存剪贴板槽位（"s"/"c"/"ca"），Excel 激活时返回 0。
- `keyFunc_pasteSystem()` / `keyFunc_paste_1()` / `keyFunc_paste_2()`：系统/CapsLock+/CapsLock+Alt 槽粘贴。
- `getSelText()`：用 `Ctrl+Insert` 安全获取选中文本（避免 IDE 里 Ctrl+C 复制整行）。
- `showMsg(msg, t:=2000)`：ToolTip 提示。
- `setSettings(sec,key,val)`：写 `CapsKeyPlusSettings.ini`。

## 配置文件

- `CapsKeyPlusSettings.ini`：`[Global]` 含 `allowClipboard`、`language`、`loadingAnimation` 等；`[Keys]` 映射热键到函数。
- `CapsKeyPlusSettingsDemo.ini`：自动生成的示例配置，只读属性，主脚本版本更新时会覆盖重建。