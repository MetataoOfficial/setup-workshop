# Neovim 配置（Neovim 0.12+，单文件，默认键优先）

整份配置只有一个 `init.lua`，只用 2～3 个插件。其余功能全部来自 Neovim 0.12 / 0.13 的内置功能。

**设计原则：能用内置键就不自定义。**

- Neovim 0.11 / 0.12 / 0.13 自带的默认键一律不覆盖，例如 `gr*`、`K`、`[d` `]d`、`gcc`、`<C-l>`、`an`/`in`、`Q`、`gQ`、`-`。
- 自定义键全部放在 `<Space>`（Leader）下，按功能分组：`b c e f g o p t u`。
- LaTeX / Python 专用键只在对应文件类型的缓冲区里存在。
- 不常用的功能做成 `:命令`，不占键。
- 在 0.12 上，多光标用插件模拟 **0.13 的默认键**。升级到 0.13 后键位不用变。

一般只用记两类东西：Neovim 的默认键（见[内置默认键速查](#内置默认键速查)），加上不到 40 个 `<Space>` 开头的键。

除了极少数几个例外：
- <C-s>: save
- F10,11,12: dark/light, insert line, insert header
- Home,End,Del,Tab,...

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
  - [已删除的旧键与替代方式](#已删除的旧键与替代方式)
  - [多光标](#多光标)
- [功能说明](#功能说明)
- [命令](#命令)
- [LSP 服务器安装](#lsp-服务器安装)
- [Treesitter 解析器](#treesitter-解析器)
- [自定义与扩展](#自定义与扩展)
- [升级到 Neovim 0.13](#升级到-neovim-013)
- [故障排查](#故障排查)
- [本版改动](#本版改动)
- [验证清单](#验证清单)

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

任何一个插件缺失，相关功能都会自动跳过，编辑器照常可用。启动后会汇总提示一次。

---

## 要求

| 项目 | 说明 |
|---|---|
| Neovim | **0.12+**（用 `nvim --version` 查看）。低于 0.12 会直接停止加载。0.13（目前为开发版）会自动改用内置多光标 |
| git | vim.pack 安装插件时必需 |
| 推荐 | `ripgrep`（全文搜索，支持实时搜索）、`fd`（查找文件更快） |
| LaTeX | `latexmk` + TeX Live / MiKTeX；PDF 阅读器（okular / evince / zathura，或系统默认程序） |
| Python | `basedpyright`、`ruff`；项目环境里装 `pytest` / `ipython`（可选） |
| 字体 | 不需要 Nerd Font（状态栏已关闭图标）；GUI 推荐 Neovide |

---

## 安装

```sh
# 1. 备份旧配置（也建议备份数据目录，避免旧插件干扰）
mv ~/.config/nvim ~/.config/nvim.bak
mv ~/.local/share/nvim ~/.local/share/nvim.bak    # 可选

# 2. 放入配置
mkdir -p ~/.config/nvim
cp init.lua ~/.config/nvim/

# 3. 国内网络（可选，第三方镜像服务）
export NVIM_PACK_MIRROR=https://ghfast.top/

# 4. 启动，首次会自动安装插件
nvim
# 或者无界面预装（服务器 / CI）：
nvim --headless +qa
```

Windows 的配置目录是 `%LOCALAPPDATA%\nvim\`，数据目录是 `%LOCALAPPDATA%\nvim-data\`。

安装完成后，建议运行 `:checkhealth vim.lsp vim.pack` 自检一次。

### 镜像是怎么生效的

镜像只在 vim.pack 调用 git 时**临时**生效。做法是用 `GIT_CONFIG_*` 环境变量加一条 `url.<镜像>.insteadOf`，执行完立即恢复，所以：

- 不会修改你的全局 `~/.gitconfig`；
- 在 `:terminal` 里运行的 git 不受影响；
- 锁文件和插件仓库的 `origin` 里始终是真实的 GitHub 地址。

同时还会临时设置"下载速度低于 1KB/s 持续 20 秒就放弃"，并关闭 git 的交互式密码提示，网络卡住时不会无限等待。

---

## 文件位置

| 路径 | 说明 |
|---|---|
| `~/.config/nvim/init.lua` | 本配置 |
| `~/.config/nvim/nvim-pack-lock.json` | 插件版本锁文件。**分享配置时请和 `init.lua` 一起提交** |
| `~/.local/share/nvim/site/pack/core/opt/` | vim.pack 的插件安装目录 |
| `~/.local/share/nvim/site/parser/` | 手动安装的 treesitter 解析器 |
| `~/.local/state/nvim/undo/` | 持久撤销文件 |

如果旧配置用过 `~/.local/share/nvim/site/pack/plugins`，启动时会提示你删除它，否则插件会被重复加载。

---

## 插件

| 插件 | 用途 |
|---|---|
| [mini.nvim](https://github.com/nvim-mini/mini.nvim) | 用到的模块：notify、starter、pairs、statusline、move、ai、extra、bufremove、git、diff、files、pick、surround、clue |
| [overseer.nvim](https://github.com/stevearc/overseer.nvim) | 任务运行器（make / npm / cargo / tasks.json / LaTeX / Python …） |
| [multicursor.nvim](https://github.com/jake-stewart/multicursor.nvim) | **只在 0.12 上安装**（`1.0` 分支），用来模拟 0.13 的内置多光标键 |

在 0.13 上，multicursor.nvim 不在插件列表里。之前装过的话，运行 `:PackClean` 删除即可。

---

## 个人设置 USER

`init.lua` 开头的 `USER` 表。一般只需要改这里：

| 键 | 默认 | 说明 |
|---|---|---|
| `author` | `nil` | `:FileHeader` 里的作者。nil 时依次读取 `git config user.name` 和系统用户名 |
| `mirror` | `$NVIM_PACK_MIRROR` | GitHub 镜像，例如 `https://ghfast.top/`；nil 表示直连 |
| `colorscheme` | `retrobox` | 内置备选：`default` / `habamax` / `unokai` 等 |
| `background` | `dark` | `<Space>ub` 可以临时切换 |
| `font` / `font_size` | `Hack` / 14 | Neovide 字体 |
| `indent` | 4 | 缩进宽度（空格） |
| `width` | 108 | 参考线画在第 `width+1` 列；同时是 `:CommentRule` / `:FileHeader` 的宽度 |
| `clipboard` | `unnamedplus` | 设为 `""` 则不与系统剪贴板同步（会在启动后延迟设置，不拖慢启动） |
| `auto_cd` | true | 打开文件时自动切换到项目根目录 |
| `root_markers` | 见文件 | 判断项目根目录的标记。同一个 `{}` 里的标记优先级相同，取离文件最近的 |
| `trim_on_save` | true | 保存时去掉行尾空白 |
| `ui2` | true | 0.12 实验性的新消息 / 命令行界面 |
| `autocomplete` | true | 边输入边弹出补全 |
| `inlay_hints` | false | LSP 内联类型提示的默认开关 |
| `native_multicursor` | true | 0.13+ 用内置多光标；设为 false 时继续用插件 |
| `latex_engine` | `-xelatex` | latexmk 引擎：`-xelatex` / `-lualatex` / `-pdf` |
| `pdf_viewers` | okular / evince / zathura | 按顺序尝试，都没有就用系统默认程序 |
| `bigfile_mb` | 5 | 超过这个大小的文件启用降级模式 |
| `extra_path` | `{ "~/.local/bin" }` | PATH 里找不到 LSP / ruff 时，再到这些目录里找。conda base 的 `bin` 会自动加入 |
| `python` | `nil` | 强制指定 Python 解释器；nil 表示自动探测 |
| `py_typecheck` | `standard` | basedpyright 检查级别：off / basic / standard / strict / recommended / all |
| `py_format_on_save` | true | 有 ruff 时保存自动格式化 |
| `py_line_length` | 88 | Python 文件的参考线位置 |

---

## 键位

`<Space>` 是 Leader，同时也是 LocalLeader。

按下 `<Space>`、`g`、`z`、`[`、`]`、`'`、`` ` ``、`"`、`<C-w>`（以及插入模式的 `<C-r>` / `<C-x>`）后停顿 0.3 秒，会弹出按键提示（mini.clue）。

想查看所有键：`<Space>fk`（快捷键查找器），或 `:verbose map <键>`。

### 内置默认键速查

下面这些都是 **Neovim 自带的键**，本配置没有改动，记住即可。

#### LSP（0.11 / 0.12）

| 键 | 功能 |
|---|---|
| `K` | 悬停文档 |
| `grn` | 重命名 |
| `gra` | 代码操作（可视模式下针对选区） |
| `grr` | 引用 |
| `gri` | 实现 |
| `grt` | 类型定义（0.12） |
| `grx` | 运行 CodeLens（0.12） |
| `gO` | 文档符号列表 |
| `<C-]>` | 跳到定义（LSP 设置了 `tagfunc`），`<C-t>` 跳回 |
| 插入模式 `<C-s>` | 签名帮助 |
| `gq{motion}` | 用 LSP 格式化一段（LSP 设置了 `formatexpr`），例如 `gqip`、`gqq` |

#### 诊断

| 键 | 功能 |
|---|---|
| `[d` / `]d` | 上 / 下一个诊断（本配置让它跳转后自动弹出浮窗） |
| `[D` / `]D` | 第一个 / 最后一个诊断 |
| `<C-w>d` | 在浮窗里显示光标处的诊断 |

#### 列表跳转（0.11，unimpaired 风格）

| 键 | 功能 |
|---|---|
| `[q` `]q` / `[Q` `]Q` | quickfix 上 / 下一项 / 首 / 尾 |
| `[l` `]l` / `[L` `]L` | location list |
| `[b` `]b` / `[B` `]B` | 缓冲区 |
| `[t` `]t` | 标签跳转 |
| `[a` `]a` | 参数列表 |
| `[<Space>` / `]<Space>` | 在上方 / 下方插入空行 |

#### 编辑与选择

| 键 | 功能 |
|---|---|
| `gc{motion}` / `gcc` | 注释 / 注释当前行 |
| `gx` | 用系统程序打开光标下的链接 / 路径 |
| 可视 `an` / `in` | 按语法节点扩大 / 缩小选区（0.12；无 treesitter 时用 LSP selectionRange） |
| 可视 `]n` / `[n` | 选中下 / 上一个同级语法节点（0.12） |
| `van` | 从普通模式开始选中当前语法节点 |
| 可视 `P` | 粘贴且**不覆盖**寄存器（可以连续粘贴） |
| `Y` | 复制到行尾（`y$`） |
| `<C-l>` | 清除搜索高亮、刷新 diff 和重绘；**0.13 还会清除多光标** |
| `&` | 用相同的标志重复上一次 `:s` |
| `*` / `#`（可视） | 搜索选中的文本 |
| `q{reg}` / `@{reg}` / `@@` | 录制宏 / 执行宏 / 重复上一次执行的宏 |

#### 补全与片段

| 键 | 功能 |
|---|---|
| `<C-n>` / `<C-p>` | 菜单下 / 上一项；菜单没打开时触发关键字补全 |
| `<C-y>` | 确认当前项（会展开 LSP 片段） |
| `<C-e>` | 关闭菜单 |
| `<C-x><C-o>` | 手动触发 LSP 补全（omnifunc） |
| `<C-x><C-f>` / `<C-x><C-l>` | 文件路径补全 / 整行补全 |
| `<Tab>` / `<S-Tab>` | 片段激活时跳到下 / 上一个占位符（0.11） |

#### 窗口

| 键 | 功能 |
|---|---|
| `<C-w>h/j/k/l` | 切换窗口 |
| `<C-w>s` / `<C-w>v` | 水平 / 垂直分屏 |
| `<C-w>c` / `<C-w>o` | 关闭当前窗口 / 只保留当前窗口 |
| `<C-w>=` | 均分窗口 |

#### 0.13 新增的默认键

| 键 | 功能 |
|---|---|
| `Q` / `[count]Q` / `gQ` | 多光标：放置或删除 / 在搜索匹配处加光标 / 找回（见[多光标](#多光标)） |
| `<C-LeftMouse>` | 鼠标放置 / 删除光标 |
| `q=` | 多光标跟随模式 |
| `-` | 打开当前文件的上级目录（内置 `dir` 插件，取代 netrw） |
| `:exmode` / `1q:` | Ex 模式（原来的 `gQ` 已让给多光标） |

### 插件默认键

这些是插件**官方默认**或社区通用的键，本配置没有改。

| 插件 | 键 | 功能 |
|---|---|---|
| mini.surround（vim-surround 风格） | `ys{motion}{char}` | 加包围，如 `ysiw"` |
| | `yss{char}` | 给整行加包围，如 `yss)` |
| | 可视 `S{char}` | 给选区加包围 |
| | `ds{char}` / `cs{old}{new}` | 删除 / 替换包围，如 `ds(`、`cs"'` |
| | `t` / `f` | 作为包围字符：HTML 标签 / 函数调用，如 `ysiwt` |
| mini.ai | `a` / `i` + 对象 | `f` 函数调用、`a` 参数、`t` 标签、`q` 引号、`b` 括号 |
| | （mini.extra） | `B` 全文、`I` 缩进块、`L` 行、`N` 数字、`D` 诊断；如 `yaB`、`dii` |
| | `al` / `il` | 上一个对象（`an` / `in` 已让给 0.12 内置的语法选区） |
| mini.move | `<M-h/j/k/l>` | 普通模式移动当前行，可视模式移动选区 |
| mini.diff | `]h` `[h` / `]H` `[H` | 下 / 上一个修改块 / 最后 / 第一个 |
| | `gh{motion}` / `ghgh` | 暂存修改（可视模式下用 `gh`） |
| | `gH{motion}` / `gHgh` | 撤销修改 |
| mini.pairs | 自动 | 自动补全括号、引号 |
| mini.files（窗口内） | `l` / `h` | 进入 / 返回上级 |
| | `=` | 应用改动（改名 / 新建 / 删除） |
| | `q` / `g?` | 关闭 / 帮助 |
| mini.pick（窗口内） | `<C-n>` / `<C-p>` | 下 / 上一项 |
| | `<CR>` / `<C-s>` / `<C-v>` / `<C-t>` | 打开 / 水平分屏 / 垂直分屏 / 新标签页 |
| | `<Tab>` / `<S-Tab>` | 预览 / 详情 |
| | `<C-x>` / `<M-CR>` | 标记 / 打开所有已标记项 |
| | `<C-Space>` / `<Esc>` | 在当前结果里继续筛选 / 关闭 |
| Overseer 任务面板 | `?` | 查看面板内所有键 |

### 本配置新增的键

所有新增的键都在 `<Space>` 下，只有少数几个例外（见表末）。

#### 文件 / 查找 / 缓冲区

| 键 | 功能 |
|---|---|
| `<Space>e` | mini.files 文件管理器（可以改名 / 新建 / 删除） |
| `<Space>bd` | 关闭缓冲区，保留窗口布局 |
| `<Space>ff` | 查找文件 |
| `<Space>fg` | 全文搜索（有 rg 或 git 时实时搜索） |
| `<Space>fw` | 搜索光标下的单词 |
| `<Space>fb` / `fo` / `fh` | 缓冲区 / 最近文件 / 帮助 |
| `<Space>fl` / `fd` / `fs` | 当前文件的行 / 诊断 / LSP 符号 |
| `<Space>fk` | 快捷键列表 |
| `<Space>fr` | 恢复上次查找 |

没有 mini.pick 时，`ff` / `fg` / `fb` / `fh` / `fo` / `fd` 会降级成内置的 `:find`、`:vimgrep`、`:b`、`:help`、`:browse oldfiles` 和诊断列表。

#### LSP / Git

| 键 | 功能 |
|---|---|
| `grd` | 跳到定义（和 `gr*` 一族对齐；内置的 `<C-]>` 也可以） |
| `<Space>cf` | 格式化整个文件（可视模式下只格式化选区） |
| `<Space>go` | 显示 / 隐藏差异叠加 |
| `<Space>gs` | 光标处的 git 提交信息 |

#### 任务（Overseer）

| 键 | 功能 |
|---|---|
| `<Space>or` | 运行任务（make / npm / cargo / tasks.json …） |
| `<Space>oo` | 任务面板 |
| `<Space>ol` | 重跑最近一个任务 |
| `<Space>oa` | 对任务执行操作（重启 / 停止 / 看输出） |
| `<Space>os` | 把 shell 命令作为任务运行 |

#### LaTeX（只在 `.tex` 文件里有效）

| 键 | 功能 |
|---|---|
| `<Space>tt` | 编译 |
| `<Space>tw` | 持续编译（`-pvc`，用 `<Space>oa` 停止） |
| `<Space>te` | 完全重建（`-gg`） |
| `<Space>tc` | 清理辅助文件（保留 PDF） |
| `<Space>tv` | 打开 PDF |

#### Python（只在 `.py` 文件里有效）

| 键 | 功能 |
|---|---|
| `<Space>pr` | 运行当前文件 |
| `<Space>pa` | 带参数运行（会记住上次输入的参数） |
| `<Space>pw` | 项目里任意文件保存后自动重跑（`<Space>oa` 停止） |
| `<Space>pd` | 在终端里运行（适合 `input()` / pdb 交互） |
| `<Space>pb` | 在当前行插入 / 删除 `breakpoint()` |
| `<Space>pt` / `pf` / `pT` | 运行光标所在的测试 / 本文件的测试 / 全部测试（pytest） |
| `<Space>pi` / `px` | ruff：整理 import / 自动修复 |
| `<Space>pv` | 选择 Python 解释器 |
| `<Space>pp` | 打开 / 收起 REPL（在 REPL 窗口里也能用） |
| `<Space>ps` | 把当前行（可视模式下是选区）发送到 REPL |

#### 开关（`<Space>u`）

| 键 | 功能 |
|---|---|
| `<Space>uu` | 撤销树（内置 `:Undotree`） |
| `<Space>uh` | LSP 内联提示 |
| `<Space>ud` | 诊断显示方式：行尾文字 ↔ 在当前行下方展开 |
| `<Space>uw` | 当前缓冲区保存时是否去掉行尾空白 |
| `<Space>uf` | Python 保存时是否自动格式化 |
| `<Space>ub` | 深色 / 浅色背景 |
| `<Space>us` | 拼写检查（已设 `cjk`，中文不会被标红） |

#### 不在 `<Space>` 下的少数几个

| 键 | 功能 | 原因 |
|---|---|---|
| `j` / `k` | 没有计数时按屏幕行移动（`gj`/`gk`），有计数时（如 `5j`）仍按真实行 | 开启了自动折行，社区通用写法 |
| 终端 `<Esc><Esc>` | 回到普通模式 | `:h terminal-input` 推荐的写法；单个 `<Esc>` 仍发给终端里的程序 |
| 命令行 `<Up>` / `<Down>` | 补全菜单打开时仍用来翻历史 | 来自 `:h wildtrigger()` 的官方示例 |
| `-`（仅 0.12） | 用 netrw 打开上级目录 | 模拟 0.13 的默认键 |
| `Q` / `gQ` / `<C-LeftMouse>`（仅 0.12） | 多光标 | 模拟 0.13 的默认键 |
| help / quickfix 窗口里的 `q` | 关闭窗口 | 和 man、checkhealth 窗口的内置行为一致 |
| Neovide `<C-=>` `<C-->` `<C-0>` | 放大 / 缩小 / 重置 | Neovide 官方 FAQ 的写法 |

### 已删除的旧键与替代方式

| 旧键 | 现在用 | 说明 |
|---|---|---|
| `<C-s>` 保存 | `:w`，或 `ZZ`（保存并退出） | 插入模式 `<C-s>` 恢复为内置的签名帮助 |
| `<Space>w` / `<Space>q` | `:w` / `:q` / `ZZ` / `ZQ` | |
| 插入模式 `<M-s>` 签名帮助 | 插入模式 `<C-s>` | 恢复内置键 |
| `<Esc>` 清除搜索高亮 | `<C-l>` | 内置；0.13 里还会清除多光标 |
| `<C-h/j/k/l>` 切换窗口 | `<C-w>h/j/k/l` | 0.13 的 `<C-l>` 有新用途，不应再覆盖 |
| `gd`（LSP 定义） | `grd` 或 `<C-]>` | `gd` 恢复为内置的"跳到局部声明" |
| `<Tab>` 多功能补全 | `<C-n>` / `<C-p>` / `<C-y>`、`<C-x><C-o>` | `<Tab>` 恢复为内置的片段跳转 + 缩进 |
| 插入模式 `<Up>` / `<Down>` 选择补全项 | `<C-n>` / `<C-p>` | |
| `<M-o>` / `<M-i>` 扩大 / 缩小选区 | 可视模式 `an` / `in` | 本来就是内置键的别名 |
| `<M-j>` / `<M-k>` 移动行 | `<M-j>` / `<M-k>`（mini.move 默认键） | 键没变，改由插件默认提供，还多了 `<M-h>` / `<M-l>` |
| 可视模式 `p` / `P` 互换 | 可视模式 `P` | 内置 `P` 本来就不覆盖寄存器 |
| `\` 替换光标下的单词 | `*` 然后 `cgn` 输入新词，`.` 逐个重复；或 LSP `grn` | |
| `<C-z>` 进入命令行 | `:` | `<C-z>` 恢复为挂起 |
| F9 深浅色 / F10 拼写 | `<Space>ub` / `<Space>us` | |
| F11 分隔线 / F12 文件头 | `:CommentRule` / `:FileHeader` | |
| `<Space>cd` / `<Space>cr` | `:CdHere` / `:CdRoot` | |
| `<Home>` / `<End>` / `<PageUp>` / `<PageDown>` | 恢复内置行为（`^` / `$` / `{` / `}` 请直接用） | |
| 插入模式 `<C-BS>` / `<C-Del>` | 插入模式 `<C-w>`（删除前一个词）/ `<C-o>dw` | |
| 插入模式 `<M-d>` 插入时间 | 插入模式 `<C-r>=strftime('%F %T')<CR>` | |
| 插入模式 `<M-=>` / `<M-->` | 删除 | |
| `<C-F4>` | `<C-w>c` | |
| `<Space>/` | `<Space>fg` | 删除重复键 |

想把某个旧键加回来，见[自定义与扩展](#自定义与扩展)。

### 多光标

键位和 **Neovim 0.13 的内置多光标完全一致**：

| 键 | 功能 |
|---|---|
| `Q` | 在主光标处放置 / 删除光标 |
| `[count]Q` | 在接下来 count 个搜索匹配处加光标（先 `/pattern` 或 `*`） |
| 可视模式 `Q` | 放置 / 删除光标 |
| `gQ` | 找回刚清除的光标 |
| `<C-LeftMouse>` | 用鼠标放置 / 删除光标 |
| `<C-l>` | 清除所有光标（同时清除搜索高亮） |
| `q=` | 跟随模式（**只有 0.13 内置版有**） |

**0.12 上用 multicursor.nvim 模拟时的额外行为：**

- 按 `Q` 放下光标后，其他光标会**暂停**，只有主光标在动。这样可以移到下一处再按 `Q`。
- `<Esc>`：如果有暂停的光标，就恢复它们；否则清除所有光标。

**用 Q 逐个放光标（0.12）：**

1. 移到第一处，按 `Q`。
2. 移到第二处，再按 `Q`。
3. 都放好后按 `<Esc>`，所有光标恢复活动，开始编辑。
4. 编辑完按 `<Esc>` 或 `<C-l>` 清除光标。

**常见用法：**

- 改某个词出现的几处：`*` 搜索，再按 `3Q` 在后面 3 处加光标，然后编辑。
- 连续几行加光标：`Q` `j` `Q` `j` `Q` …… 然后 `<Esc>`。
- 只是替换同一个词，不一定需要多光标：`*` → `cgn` → 输入新词 → `.` `.` `.`。改变量名用 LSP `grn` 更可靠。

**和旧行为的差别（0.12 和 0.13 一样）：**

- `Q` 不再重放宏，改用 `@@`。`@@` 重复的是「上一次执行的」寄存器，所以录完宏后第一次要用 `@q`。
- 0.12 的 `gQ`（Ex 模式）不再可用；0.13 改用 `:exmode`。

**0.13 上：** 默认（`USER.native_multicursor = true`）直接使用内置多光标，不安装插件，详细用法见 `:h multicursor`。内置版的细节（比如放光标后其他光标是否暂停）可能和插件不同，以 `:h` 为准。

---

## 功能说明

### 补全

**插入模式：**

- 没有 LSP 的缓冲区用 0.12 原生的 `'autocomplete'`，打字时自动弹出关键字补全。
- 挂上 LSP 后，该缓冲区的原生自动补全会关掉，改由 `vim.lsp.completion` 自动弹出，同时支持片段展开。
- 本配置把字母和 `_` 加进了 LSP 的触发字符，所以输入标识符时也会弹出补全，不只在 `.` 后面。这是 `:h lsp-attach` 示例里的做法。
- 如果你的构建里 `'autocomplete'` 不能按缓冲区关闭，会保留原生补全，LSP 补全改用 `<C-x><C-o>` 手动触发，不会同时出现两个菜单。
- `completeopt` 设置了 `noselect,fuzzy,popup`：默认不选中任何项，支持模糊匹配，并在旁边的弹窗里显示文档。

**命令行：** 在 `:`、`/`、`?` 里边输入边弹出补全菜单（`wildtrigger()`），支持模糊匹配，`'path'` 包含 `**`。菜单打开时 `<Up>` / `<Down>` 仍然用来翻命令历史，`<Tab>` 选择补全项。

### LSP

- 服务器用 `vim.lsp.config` 定义、`vim.lsp.enable` 启用。可执行文件依次在 PATH、`USER.extra_path`、conda base 的 bin 目录里查找，找不到的服务器会被跳过。
- 挂载后，按服务器支持的能力启用：自动补全、LSP 折叠（没有 treesitter 时）、内联提示（`USER.inlay_hints`）、联动编辑（改 HTML 开标签时同步改闭标签）、CodeLens（用内置 `grx` 运行）。
- 诊断：行尾显示文字，按严重程度排序；`[d` / `]d` 跳转后自动弹出浮窗；`<Space>ud` 可以切换为在当前行下方展开显示（长消息不会被截断）。
- 大文件不挂 LSP。
- 用 `:lsp` 交互式地查看、重启、停止 LSP 客户端（0.12 内置）。

### ui2（实验性）

启用后：

- 没有 "Press ENTER" 提示；
- 命令行会随输入高亮；
- `:messages` 用可滚动的窗口显示。

如果遇到兼容问题，把 `USER.ui2` 设为 `false`。

### 文件浏览

| 方式 | 适合 |
|---|---|
| `-` | 打开当前文件所在目录，再按 `-` 继续往上一级。0.13 用内置 `dir`（只读），0.12 用 netrw |
| `<Space>e` | mini.files：像编辑文本一样改名 / 新建 / 删除文件，按 `=` 应用 |
| `<Space>ff` / `<Space>fo` | 按名字查找文件 / 最近文件 |

### 项目根目录

打开文件时自动 `cd` 到项目根目录，Overseer 和查找都以它为准。

- `Makefile` / `justfile` / `package.json` / `pyproject.toml` / `Cargo.toml` / `pubspec.yaml` 优先于 `.git`。所以在 monorepo 的子包里，会停在子包目录。
- 家目录本身是 dotfiles 仓库时，不会切到 `~`，而是停在文件所在目录。
- 终端、帮助、目录缓冲区（netrw / 0.13 dir）等特殊缓冲区不会触发切换。
- `:CdHere`：切到当前文件所在目录，并暂停自动切换；`:CdRoot`：回到项目根目录，并恢复自动切换。

### 保存时去掉行尾空白

默认开启，以下情况会跳过：

- markdown / diff 文件（markdown 里行尾两个空格表示换行）；
- 二进制文件、不可修改的缓冲区、大文件；
- 项目的 `.editorconfig` 写了 `trim_trailing_whitespace = false`；
- 用 `<Space>uw` 关掉了当前缓冲区；
- 全局关闭：把 `USER.trim_on_save` 设为 `false`。

去空白时会保留光标位置，也不会改动搜索历史。

### 大文件（> `bigfile_mb`）

以下功能会关掉：treesitter 和 syntax 高亮、折叠（改为手动）、十字光标线、LSP、mini.diff、undo 文件、swap 文件、保存时去行尾空白、Python 保存时格式化。

### 折叠

- 默认按缩进折叠。
- 有 treesitter 解析器时用 treesitter 折叠；没有解析器但 LSP 支持 foldingRange 时用 LSP 折叠。
- 折叠方式记在缓冲区上，同一个文件在任何窗口里打开都用同一种。
- 打开文件时默认全部展开（`foldlevel=99`）。折叠行保留原文的语法高亮。
- 常用内置键：`za` 切换、`zc` / `zo` 关 / 开、`zM` / `zR` 全关 / 全开。

### Git（mini.git + mini.diff）

- 行号旁的标记栏显示增 / 删 / 改。
- `]h` / `[h` 在修改块之间跳转；`ghgh` 暂存光标处的块，`gHgh` 撤销。
- `<Space>go` 在缓冲区里叠加显示差异；`<Space>gs` 显示光标处那一行的提交信息。
- `:Git <子命令>` 执行任意 git 命令（mini.git）。

### LaTeX

- 编译参数：`-synctex=1 -file-line-error -interaction=nonstopmode -halt-on-error`，引擎由 `USER.latex_engine` 决定。
- 编译前会自动保存。
- 用 Overseer 编译失败时，会自动打开 quickfix 并列出错误（`[q` / `]q` 跳转）。
- 没有 Overseer 时，在底部终端里运行。
- `<Space>tv` 依次尝试 `USER.pdf_viewers` 里的阅读器，都没有就用系统默认程序（`vim.ui.open`，macOS / Windows 也能用）。
- 反向搜索（在 PDF 里点击跳回源码）：以 zathura 为例，用 `nvim --listen /tmp/nvim.sock` 启动，再在 zathura 里配置：
  ```
  set synctex-editor-command "nvim --server /tmp/nvim.sock --remote-send '<C-\\><C-n>:e %{input}<CR>:%{line}<CR>'"
  ```
  具体语法以 zathura 文档为准。

### Python

**解释器自动探测**（basedpyright、运行、测试、REPL 都用同一个），优先级从高到低：

1. `<Space>pv` 手动选择的（按项目分别记住）
2. `USER.python`
3. `$VIRTUAL_ENV`
4. 项目内的 `.venv` / `venv` / `env`（也可以是指向 conda 环境的软链接）
5. `$CONDA_PREFIX`（当前激活的 conda 环境）
6. conda base（从桌面启动、没有激活环境时）
7. PATH 里的 `python3` / `python`

**其他：**

- **LSP：** basedpyright 负责类型检查和补全，ruff 负责 lint、格式化和整理 import。有 ruff 时，basedpyright 的"整理 import"会关闭，`K` 只显示 basedpyright 的文档。
- **保存时格式化：** 有 ruff 时自动执行，`<Space>uf` 切换。
- **运行结果：** traceback 会被解析进 quickfix。pytest 用 `--tb=line`，失败位置同样进入 quickfix。
- **`<Space>pt`：** 自动找到光标所在的 `test_` 函数，包括外层的 `class`，生成 `path::Class::test_name`。
- **REPL：** 解释器所在目录里有 ipython 就用 ipython（括号粘贴，多行代码块最稳），否则用普通 python。多行代码会经临时文件执行。发送前会自动去掉公共缩进。
- **缩进：** 续行缩进为 1 个 `shiftwidth`（PEP 8 风格）。参考线在第 `py_line_length + 1` 列。

### Overseer

- 所有任务在启动和结束时都会弹出通知。Neovim 窗口不在前台时，结束通知还会以桌面通知发出。
- 任务面板在右侧，按 `?` 查看面板里的键。
- 本配置复制了 Overseer v2 官方的 `default` 组件列表，并加上了"启动通知"。升级 Overseer 后，如果官方默认组件有变化，需要对照 `:h overseer` 手动同步。

### 注释装饰

- `:CommentRule`：插入一条注释分隔线。当前行为空时替换该行，否则插到下方。
- `:FileHeader`：插入文件头（文件名 / 创建时间 / 作者），会自动跳过 shebang 和 `<?xml`，已有文件头时不会重复插入。
- 注释符号来自 `'commentstring'`，`/* */` 这类成对注释也能正确对齐。

### Neovide

字体由 `USER.font` / `USER.font_size` 设置，另外设置了内边距、动画、透明度和模糊。`<C-=>` / `<C-->` / `<C-0>` 用 `neovide_scale_factor` 缩放整个界面。

---

## 命令

| 命令 | 说明 |
|---|---|
| `:PackUpdate [名字…]` | 检查更新（Tab 可以补全插件名）。确认页里 `:write` 应用、`:quit` 放弃，应用后 `:restart` |
| `:PackSync` | 把插件恢复到锁文件记录的版本（换机器 / 回滚时用） |
| `:PackClean` | 删除不在插件列表里的插件（例如升级 0.13 后的 multicursor.nvim） |
| `:restart` | 重启 Neovim（0.12 内置） |
| `:Undotree` | 撤销树（`<Space>uu`） |
| `:DiffTool a b` | 对比两个目录 / 文件（0.12 内置） |
| `:lsp` | 交互式地查看、重启、停止 LSP 客户端（0.12 内置） |
| `:checkhealth vim.lsp vim.pack` | 自检 |
| `:CommentRule` / `:FileHeader` | 注释分隔线 / 文件头 |
| `:CdHere` / `:CdRoot` | 切到文件目录（暂停自动 cd）/ 回到项目根目录（恢复自动 cd） |
| `:Git …` | 执行 git 命令（mini.git） |
| `:OverseerRun` / `:OverseerShell …` | 运行任务 / 把 shell 命令作为任务运行 |
| `:lua MiniNotify.show_history()` | 通知历史 |
| `:verbose map <键>` | 查看某个键最后是在哪里定义的 |

---

## LSP 服务器安装

没安装的服务器会被自动跳过。要新增服务器，在 `init.lua` 第 9 节的 `servers` 表里加一项即可。

| 服务器 | 语言 | 安装示例 |
|---|---|---|
| basedpyright | Python | `pipx install basedpyright`，或 `uv tool install basedpyright` |
| ruff | Python | `pipx install ruff`，或 `uv tool install ruff` |
| lua_ls | Lua | 用包管理器安装 `lua-language-server` |
| bashls | Bash | `npm i -g bash-language-server` |
| dartls | Dart | 随 Dart / Flutter SDK 附带 |

新增服务器的例子：

```lua
clangd = {
  cmd = { "clangd" }, filetypes = { "c", "cpp" },
  root_markers = { "compile_commands.json", ".clangd", ".git" },
},
```

---

## Treesitter 解析器

Neovim 自带的解析器只有 c、lua、markdown、vim、vimdoc、query 等几种（0.13 另加 diff），其他语言默认用传统的正则高亮。要为更多语言启用 treesitter 高亮和折叠，可以用以下任一方式：

- 安装 [nvim-treesitter](https://github.com/nvim-treesitter/nvim-treesitter) 的 `main` 分支（需要 `tree-sitter` CLI），在 `PLUGINS` 里加上它，然后 `:TSInstall python bash latex …`；
- 或者手动把 `python.so` 放进 `~/.local/share/nvim/site/parser/`，并把对应的 queries 放进 `site/queries/python/`。

装好解析器后，配置会自动为对应语言启用 treesitter 高亮和折叠，可视模式 `an` / `in` 也会改用 treesitter，不需要再改配置。

---

## 自定义与扩展

把下面的代码加在 `init.lua` 末尾即可。

**加回 `<C-s>` 保存**（会占用插入模式的签名帮助）：

```lua
vim.keymap.set({ "n", "x" }, "<C-s>", "<cmd>update<cr>", { desc = "Save" })
```

**加回 `<Esc>` 清除搜索高亮**（kickstart.nvim 的写法）：

```lua
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<cr>")
```

**加回 `<C-h/j/k/l>` 切换窗口**（注意：会盖掉 `<C-l>` 的清高亮，在 0.13 上还会盖掉清除多光标）：

```lua
for _, k in ipairs({ "h", "j", "k", "l" }) do
  vim.keymap.set("n", "<C-" .. k .. ">", "<C-w>" .. k)
end
```

**0.13 上恢复 `Q` 重放宏**（`:h news` 给出的写法，会放弃多光标的 `Q`）：

```lua
vim.keymap.set("n", "Q", function()
  local reg = vim.fn.reg_recorded()
  return reg == "" and "" or ("@" .. reg)
end, { expr = true })
```

**新增插件：** 在 `PLUGINS` 里加 `{ src = "https://github.com/作者/仓库" }`，再用 `use("模块名", function(m) m.setup() end)` 加载。出错时只会跳过这一块。

---

## 升级到 Neovim 0.13

0.13 目前还是开发版（nightly），以下内容依据 `:h news`，正式发布时可能还会变化。

1. 升级后第一次启动，配置会自动改用内置多光标，不再加载 multicursor.nvim。运行 `:PackClean` 删除它。
2. 多光标键位不变（`Q` / `[count]Q` / `gQ` / `<C-LeftMouse>` / `<C-l>`），另外多了 `q=` 跟随模式。
3. `-` 改由内置 `dir` 插件提供（只读）。netrw 默认不再加载，需要时用 `:packadd netrw`。要改文件请用 `<Space>e`（mini.files）。
4. Ex 模式改用 `:exmode` 或 `1q:` 进入。
5. `'autoread'` 改用文件系统监视，外部修改会实时检测到。
6. mini.clue 的旧版本会映射 `Q` 来重放宏，会盖掉内置多光标。请先 `:PackUpdate mini.nvim` 更新到最新版。
7. 如果内置多光标和你的工作流有冲突，可以先设 `USER.native_multicursor = false`，继续用插件。

---

## 故障排查

| 现象 | 处理 |
|---|---|
| 启动时提示有插件未加载 | 检查 git 和网络；国内网络请设置 `NVIM_PACK_MIRROR`；然后重启 |
| 插件目录里只有 `.git`，内容是空的 | 配置会自动删掉这种目录，重启后重新安装 |
| `vim.pack 出错` | 配置会降级为直接加载本地已有的插件。网络恢复后重启即可 |
| 界面 / 消息显示异常 | 把 `USER.ui2` 设为 `false` |
| 同时弹出两个补全菜单，或输入的字符被吞掉 | 把 `USER.autocomplete` 设为 `false` |
| 有 LSP 的文件里没有自动补全 | `:checkhealth vim.lsp`；用 `<C-x><C-o>` 手动触发试试 |
| `Q` 的行为不对 | `:verbose nmap Q` 查看最后是在哪里定义的。0.12 上应来自 `init.lua`；0.13 上应该没有用户映射。来自 mini.clue 时请更新 mini.nvim |
| `5Q` 提示"还没有搜索过" | 先用 `/pattern` 或 `*` 搜索，再按 `[count]Q` |
| `<C-l>` 没有清除多光标 | 有别的配置或插件映射了 `<C-l>`，用 `:verbose nmap <C-l>` 查找 |
| `-` 没反应 | 0.12 需要 netrw（默认启用）；检查是否设置了 `g:loaded_netrwPlugin` |
| `<Space>t…` / `<Space>p…` 不存在 | 这些键只在 `.tex` / `.py` 缓冲区里有效 |
| Python 报"无法解析导入" | `<Space>pv` 选择正确的解释器；或在项目里建 `.venv` |
| 保存时没有格式化 | 确认 ruff 已安装且已挂载（`:lsp`）；`<Space>uf` 是否被关闭 |
| LaTeX 报 Overseer 组件参数错误 | 删掉 `run_job` 里的 `open_on_exit` / `items_only` 两个参数 |
| Big5 文件显示乱码 | `:e ++enc=big5` |
| LSP 没有启动 | `:checkhealth vim.lsp`；确认服务器命令在 `$PATH` 或 `USER.extra_path` 里 |

---

## 本版改动

**原则：默认键优先**

- 删除所有和内置键重复或冲突的自定义键：`<C-s>`、`<Esc>` 清高亮、`<C-h/j/k/l>`、`<C-z>`、`<Tab>` / `<S-Tab>`、插入模式方向键、`<M-o>` / `<M-i>`、可视 `p` / `P` 互换、`\`、`<Home>` / `<End>` / `<PageUp>` / `<PageDown>`、`<C-BS>` / `<C-Del>`、`<M-d>`、`<M-=>` / `<M-->`、`<C-F4>`、`<M-s>`、`<Space>w` / `<Space>q` / `<Space>/`。
- 恢复的内置功能：插入模式 `<C-s>` 签名帮助、`<C-l>` 清高亮（0.13 还会清除多光标）、`<Tab>` 片段跳转、`<C-z>` 挂起、可视 `P`、`gd`。
- LSP 跳到定义从 `gd` 改为 `grd`（与 `gr*` 一族对齐）；局部格式化用内置 `gq`。
- 移动行改用 mini.move 的默认键 `<M-h/j/k/l>`。
- F9 / F10 → `<Space>ub` / `<Space>us`；F11 / F12 → `:CommentRule` / `:FileHeader`；`<Space>cd` / `<Space>cr` → `:CdHere` / `:CdRoot`。

**向 0.13 看齐**

- 0.12 上补齐 0.13 的多光标默认键：`<C-l>` 清除、`<C-LeftMouse>` 鼠标放置。
- `-` 在 0.12 上用 netrw 模拟 0.13 内置 `dir` 的行为；在 0.13 上不做任何映射。netrw 选项只在 0.12 上设置。
- 修正旧文档里"`<C-l>` 本来就是切换窗口"的错误说法。

**结构与正确性**

- LaTeX / Python 的键改为只在对应文件类型里生效（`<LocalLeader>` + FileType），不再全局占用。
- `<Space>pp` 在 REPL 窗口里也能收起 REPL。
- 自动 cd 会跳过目录缓冲区（netrw / 0.13 dir）。
- `q` 关闭只用于 help / quickfix，man / checkhealth 内置已有，不再重复映射。
- Neovide 缩放改用官方的 `neovide_scale_factor`。
- 新增 `HAS_013` / `IS_WIN` 常量，统一版本判断；用户命令统一用 `cmd()` 定义。

---

## 验证清单

以下几项用到了 0.12 / 0.13 较新或实验性的接口，都做了保护，失败只会跳过该功能。第一次使用时建议逐项确认：

- [ ] 插入模式打字时有补全弹出；在有 LSP 的文件里，菜单里是 LSP 的补全项；`<C-y>` 能确认
- [ ] 插入模式 `<C-s>` 弹出签名帮助
- [ ] 输入 `:e ` 时自动弹出文件补全，`<Up>` 仍能翻历史
- [ ] 可视模式 `an` / `in` 能扩大 / 缩小选区
- [ ] `<C-l>` 能清除搜索高亮
- [ ] `-` 能打开上级目录
- [ ] `<Space>uu` 能打开撤销树
- [ ] 在 `.tex` 里 `<Space>tt` 编译出错时，quickfix 能自动打开
- [ ] 在 `.py` 里 `<Space>pr` 能运行，`<Space>pv` 能列出解释器
- [ ] `:checkhealth vim.lsp vim.pack` 没有 deprecated 警告
- [ ] 0.12：`:verbose nmap Q` 显示来自 `init.lua` 的映射；`Q` 能放置光标，`<Esc>` 能恢复 / 清除，`<C-l>` 能清除
