# Neovim 配置（Neovim 0.12+，单文件，默认键优先）

整份配置只有一个 `init.lua`，只用 2～3 个插件。其余功能全部来自 Neovim 0.12 / 0.13 的内置功能。

**设计原则：能用内置键就不自定义；少量例外必须有明确理由。**

- `Q` / `gQ` / `-` 等兼容键只用于在 0.12 上模拟 0.13 行为；保存、折行等少数人体工学键另有说明。
- 工作流键主要放在 `<Space>`（Leader）下，按功能分组：`b c e f g o p t u`。
- LaTeX / Python / Go 专用键只在对应文件类型的缓冲区里存在。
- 不常用的功能做成 `:命令`，不占键。
- 在 0.12 上，多光标用插件模拟 **0.13 的默认键**。升级到 0.13 后键位不用变。

---

## 目录

- [内置功能一览](#内置功能一览)
- [要求](#要求)
- [安装](#安装)
- [文件位置](#文件位置)
- [插件](#插件)
- [个人设置 USER](#个人设置-user)
- [键位](#键位)
  - [内置默认键速查](#内置默认键速查)
  - [插件默认键](#插件默认键)
  - [本配置新增的键](#本配置新增的键)
  - [多光标](#多光标)
- [功能说明](#功能说明)
  - [按键提示机制](#按键提示机制-miniclue)
  - [mini.nvim 上下文记忆](#mininvim-上下文记忆)
  - [补全与 LSP](#补全与-lsp)
  - [Python](#python)
  - [Go](#go)
  - [LaTeX](#latex)
  - [Overseer](#overseer)
- [命令](#命令)
- [升级到 Neovim 0.13](#升级到-neovim-013)
- [故障排查](#故障排查)

---

## 内置功能一览

| 功能 | 来源 |
|---|---|
| 插件管理 | `vim.pack`（0.12） |
| 插入模式自动补全 | `'autocomplete'`（0.12）+ `vim.lsp.completion` |
| 命令行实时补全 | `wildtrigger()`（0.12） |
| 消息 / 命令行界面 | ui2（0.12，实验性） |
| 撤销树 | `:Undotree`（`nvim.undotree`，0.12） |
| 目录对比 | `:DiffTool`（`nvim.difftool`，0.12） |
| LSP | `vim.lsp.config` / `vim.lsp.enable`、`:lsp` 命令 |
| 增量选择 | 可视模式 `an` / `in` / `]n` / `[n`（0.12） |
| 高亮 / 折叠 | treesitter，以及 LSP foldingRange |
| 注释 | `gc` / `gcc`（0.10） |
| 片段 | `vim.snippet`，`<Tab>` / `<S-Tab>` 跳转（0.11） |
| EditorConfig | 内置 |
| 多光标 | 0.13 内置；0.12 用 multicursor.nvim 模拟同一套键 |
| 目录浏览 `-` | 0.13 内置 `dir`；0.12 用 netrw 模拟同一个键 |

---

## 要求

| 项目 | 说明 |
|---|---|
| Neovim | **0.12+**（用 `nvim --version` 查看）。低于 0.12 会停止加载。0.13+ 自动使用内置多光标 |
| git | vim.pack 安装插件时必需 |
| 推荐外部工具 | `ripgrep`（全文搜索 / 实时 grep）、`fd`（快速文件检索） |
| LaTeX | `latexmk` + TeX Live / MiKTeX；PDF 阅读器（okular / evince / zathura，或系统默认程序） |
| Python | `basedpyright`、`ruff`；项目环境装 `pytest` / `ipython`（可选） |
| Go | `go`；`gopls` 提供 LSP 补全、格式化与 import 整理 |
| 字体 | 不需要 Nerd Font（状态栏已关闭图标）；GUI 推荐 Neovide |

---

## 安装

```sh
# 1. 备份旧配置与数据
mv ~/.config/nvim ~/.config/nvim.bak
mv ~/.local/share/nvim ~/.local/share/nvim.bak    # 可选

# 2. 写入配置
mkdir -p ~/.config/nvim
cp init.lua ~/.config/nvim/

# 3. 国内网络加速（可选，第三方镜像）
export NVIM_PACK_MIRROR=https://ghfast.top/

# 4. 首次启动会自动安装插件
nvim
# 或无界面预装（服务器 / 容器）：
nvim --headless +qa
```

Windows 配置目录为 `%LOCALAPPDATA%\nvim\`，数据目录为 `%LOCALAPPDATA%\nvim-data\`。

---

## 插件

| 插件 | 用途 |
|---|---|
| [mini.nvim](https://github.com/nvim-mini/mini.nvim) | notify, starter, pairs, statusline, tabline, move, indentscope, cursorword, ai, extra, bufremove, sessions, visits, git, diff, files, pick, surround, clue |
| [overseer.nvim](https://github.com/stevearc/overseer.nvim) | 现代化任务运行器（LaTeX / Python / Go / Make / npm 等） |
| [multicursor.nvim](https://github.com/jake-stewart/multicursor.nvim) | **仅在 0.12 环境下安装**，用于模拟 0.13 的原生多光标行为 |

---

## 个人设置 USER

在 `init.lua` 开头的 `USER` 表配置：

| 键 | 默认 | 说明 |
|---|---|---|
| `author` | `nil` | `:FileHeader` 作者。nil 时自动读取 git config 用户名 |
| `mirror` | `$NVIM_PACK_MIRROR` | GitHub 镜像代理地址，如 `https://ghfast.top/` |
| `colorscheme` | `retrobox` | 内置主题备选：`default` / `habamax` / `unokai` |
| `background` | `dark` | `F10` 键可随时切换深浅色 |
| `indent` | 4 | 缩进空格宽度 |
| `width` | 90 | 列标尺线位置及代码分割线宽度 |
| `clipboard` | `unnamedplus` | 与系统剪贴板同步（延迟加载，不拖慢冷启动） |
| `auto_cd` | true | 打开文件时自动 cd 到项目根目录 |
| `trim_on_save` | true | 保存文件时自动去除行尾空白字符（可局部切换） |
| `ui2` | true | 启用 0.12 实验性消息与命令行界面（无 Press ENTER） |
| `autocomplete` | true | 输入时自动弹出补全建议 |
| `inlay_hints` | false | LSP 内联类型提示默认开关 |
| `native_multicursor` | true | 0.13+ 环境使用内置多光标实现 |
| `latex_engine` | `-xelatex` | latexmk 编译引擎参数 |
| `py_format_on_save` | true | 保存 Python 文件时使用 ruff 自动格式化 |
| `go_format_on_save` | true | 保存 Go 文件时使用 gopls 自动格式化 |

---

## 键位

### 按键提示机制（mini.clue）
- **仅针对 `<Leader>` 生效**：输入 `<Space>` 并停顿 600ms 后会弹出导航菜单，帮助提示子命令分组。
- **杜绝干扰原生 Motion**：配置**移除了**对 `g`、`z`、`[`、`]`、`<C-w>` 的 clue 拦截。敲击 `1333gg`、`5j`、`g_`、`grn` 等原生按键时，绝不会丢失 count（计数值）或产生输入顿挫。

### 内置默认键速查

| 分类 | 快捷键 | 功能 |
|---|---|---|
| **LSP** | `K` | 悬停文档浮窗 |
| | `grn` / `gra` | 变量重命名 / Code Action 代码操作 |
| | `grr` / `gri` / `grt` | 查看引用 / 实现 / 类型定义 |
| | `grx` / `gO` | 运行 CodeLens / 文档大纲符号列表 |
| | `<C-]>` / `<C-t>` | 跳转至定义 / 返回原处 |
| | `gq{motion}` | 使用 LSP 对选定区域格式化 |
| **诊断** | `[d` / `]d` | 上 / 下一个诊断（跳转后自动展开浮窗提示） |
| | `[D` / `]D` | 首个 / 末尾诊断项 |
| | `<C-w>d` | 打开光标所在处的诊断详细浮窗 |
| **列表跳转** | `[q` / `]q` | Quickfix 列表上 / 下项 |
| | `[b` / `]b` | Buffer 列表上 / 下项 |
| | `[<Space>` / `]<Space>` | 在当前行上方 / 下方插入空行 |
| **编辑** | `gc{motion}` / `gcc` | 行注释 / 块注释切换 |
| | 可视模式 `an` / `in` | 扩大 / 缩小语义语法节点选区（Treesitter / LSP） |
| | `<C-l>` | 清除搜索高亮、刷新屏幕（0.13+ 同时清除所有多光标） |
| **补全与片段** | `<C-n>` / `<C-p>` | 补全菜单下 / 上项选择 |
| | `<C-y>` / `<C-e>` | 确认选中项 / 关闭补全菜单 |
| | `<Tab>` / `<S-Tab>` | 片段占位符下 / 上跳转；无片段时向下选菜单或触发补全 |
| | `<C-x><C-o>` | 手动强制触发 LSP 补全 |

### 本配置新增的 `<Leader>` 键位（`<Space>`）

#### 文件、搜索与上下文（`<Space>f` / `<Space>b` / `<Space>e`）
- `<Space>e`：打开 `mini.files` 目录树（可在缓冲区内直接修改文件名、回车建立文件、`=` 应用）。
- `<Space>bd`：关闭当前 buffer，保持窗口切分布局不乱（`mini.bufremove`）。
- `<Space>ff`：查找项目内文件（自动适配 `fd` / `rg`）。
- `<Space>fg` / `<Space>fw`：全文实时检索 / 检索光标所在词。
- `<Space>fb` / `<Space>fo` / `<Space>fh`：缓冲区列表 / 最近打开的文件 / 帮助文档。
- `<Space>fl` / `<Space>fd` / `<Space>fs`：检索当前文件行 / 诊断列表 / LSP 符号。
- `<Space>fv` / `<Space>fV`：查看当前项目 / 全局的高频访问文件（`mini.visits`）。
- `<Space>fS` / `<Space>fR` / `<Space>fW` / `<Space>fD`：会话管理：选择 / 载入 / 保存 / 删除 Session。

#### 代码与重构（`<Space>c` / `gr*`）
- `grd`：跳转到符号定义（与内置 `grn`/`gra` 对齐）。
- `<Space>cf`：调用 LSP 格式化整个当前文件。
- `<Space>go` / `<Space>gs`：差异叠加对比 / 查看光标所在行的 Git Commit 详情。

#### 任务系统 Overseer（`<Space>o`）
- `<Space>or`：选择并运行任务（自动识别 Make / npm / Cargo / pytest 等）。
- `<Space>oo`：打开 / 隐藏右侧任务监控面板。
- `<Space>ol`：重跑最近一次运行的任务。
- `<Space>oa`：查看任务操作选项（查看日志、终止、重跑）。
- `<Space>os`：直接将自定义 Shell 命令放入后台作为任务执行。

#### 语言专用快捷键（仅在对应文件类型生效）
- **Python（`.py`）**：
  - `<Space>pr` / `<Space>pa`：运行当前文件 / 带参数运行。
  - `<Space>pw`：保存文件即触发自动重跑。
  - `<Space>pd`：进入终端运行模式（用于 `input()`、`breakpoint()`、`pdb` 交互）。
  - `<Space>pb`：在当前行快速插入或删除 `breakpoint()`。
  - `<Space>pt` / `<Space>pf` / `<Space>pT`：运行光标所在处测试 / 文件测试 / 项目全量 pytest。
  - `<Space>pi` / `<Space>px`：通过 ruff 自动整理 imports / 应用全部代码修复规则。
  - `<Space>pv`：交互式选择当前项目的 Python 虚拟环境/解释器。
  - `<Space>pp`：打开 / 收起 Python REPL 交互窗口。
  - `<Space>ps`：向 REPL 发送当前行（可视模式下为发送选区）。
- **Go（`.go`）**：
  - `<Space>gr`：运行当前 Go 包（`go run .`）。
  - `<Space>gt`：快速运行光标所在的单个 Test / Benchmark / Example 函数。
  - `<Space>gf` / `<Space>gT`：测试当前包 / 测试项目全量包（`./...`）。
  - `<Space>gb`：构建检查（`go build ./...`）。
  - `<Space>gF` / `<Space>gi`：调用 gopls 格式化代码 / 自动整理 import。
- **LaTeX（`.tex`）**：
  - `<Space>tt` / `<Space>tw`：编译 / 持续监听编译（`-pvc`）。
  - `<Space>te` / `<Space>tc`：全量清理重建 / 清除编译缓存文件。
  - `<Space>tv`：打开 PDF 预览阅读器。

#### 实用开关（`<Space>u`）
- `<Space>uu`：切换展示内置撤销树（`:Undotree`）。
- `<Space>uh`：切换 LSP 内联类型提示（Inlay Hints）。
- `<Space>ud`：切换诊断信息展示方式（行尾文本 ↔ 换行完整展开）。
- `<Space>uw`：切换当前 buffer 是否在保存时去行尾空白。
- `<Space>uf` / `<Space>uG`：切换 Python（ruff）/ Go（gopls）保存时自动格式化开关。
- `<Space>us`：切换拼写检查（中日韩文本自动忽略标红）。

#### 少数非 Leader 扩展键
- `<C-s>`：智能保存（适配所有模式，过滤非文件类型 buffer 并抑制冗长报错）。
- `j` / `k`：按屏幕视觉行移动；输入数字计数（如 `5j`）时恢复为物理行跳转。
- `<F10>`：快速切换 Dark / Light 主题明暗模式。
- `<F11>` / `<F12>`：插入注释分割线（`:CommentRule`）/ 插入文件信息头（`:FileHeader`）。
- `q`（在 help、quickfix 窗口中）：一键关闭当前窗口。
- 终端模式下 `<Esc><Esc>`：退出终端输入模式回到 Normal 模式。

---

## 多光标

多光标按键规范完全对齐 **Neovim 0.13 原生多光标键位**：

| 快捷键 | 功能说明 |
|---|---|
| `Q` | 在当前光标处放置 / 移除辅助光标 |
| `[count]Q` | 在接下来的 count 个搜索匹配项处添加光标（先按 `/` 或 `*` 搜索） |
| `gQ` | 重新找回最近一次清除的多光标 |
| `<C-LeftMouse>` | 用鼠标左键在指定位置添加 / 移除光标 |
| `<C-l>` | 清除屏幕所有辅助光标（并清除搜索高亮） |

- **0.12 环境**：由 `multicursor.nvim` 提供驱动。按 `Q` 后其他光标暂停，按 `<Esc>` 恢复所有光标并进入同步编辑状态。
- **0.13+ 环境**：配置自动检测并切换到 Neovim 内置多光标引擎，额外支持 `q=` 进入跟随模式。

---

## 升级到 Neovim 0.13

当你的 Neovim 构建环境升级到 0.13+ 时：
1. 首次打开会自动切入原生多光标驱动，执行 `:PackClean` 命令可一键卸载多余的 `multicursor.nvim`。
2. 原生内置的 `dir` 插件将替代 netrw 接管 `-` 路径导航。
3. `vim.hl.hl_op` 将自动接管 Yank 高亮，与未来弃用机制无缝衔接。
4. 本配置的所有快捷键行为保持 100% 一致，无需重新适应。

---

## 故障排查

| 现象 | 原因分析与处理方案 |
|---|---|
| **`1333gg` 偶发跳到首行** | 现已通过移除 `mini.clue` 对 `g` 的拦截、延长 `timeoutlen` 至 1000ms 彻底解决。如在极端网络延迟/掉字环境下，推荐使用键位击键更少的 `1333G`。 |
| **输入代码偶发卡顿** | 检查命令行正则或 LSP 补全触发。当前已取消对全字母盲目挂载 triggerCharacters，只使用服务器官方字符声明。 |
| **Python 报“无法解析导入”** | 按 `<Space>pv` 手动选择或绑定正确的环境路径；项目根目录下推荐直接放置 `.venv`。 |
| **保存文件未格式化** | 检查外部工具是否在系统 PATH 中；按 `<Space>uf` 或 `<Space>uG` 确认当前语言自动格式化未被关闭。 |
| **国内插件下载失败** | 在命令行配置镜像环境参数：`export NVIM_PACK_MIRROR=https://ghfast.top/` 后重启编辑器。 |
