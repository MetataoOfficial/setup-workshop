# Neovim 配置（Neovim 0.12+，单文件）

整份配置只有一个 `init.lua`，只用 3 个插件，其余全部是 Neovim 0.12 的内置功能：

- 插件管理：`vim.pack`
- 补全：`'autocomplete'` 和 `vim.lsp.completion`
- 命令行实时补全：`wildtrigger()`
- 消息 / 命令行界面：ui2
- 撤销树：`nvim.undotree`
- LSP：`vim.lsp.config`
- 高亮 / 折叠：treesitter
- EditorConfig

任何一个插件缺失，相关功能都会自动跳过，编辑器照常可用。

## 目录

- [要求](#要求)
- [安装](#安装)
- [插件](#插件)
- [个人设置 USER](#个人设置-user)
- [键位](#键位)
- [功能说明](#功能说明)
- [命令](#命令)
- [LSP 服务器安装](#lsp-服务器安装)
- [Treesitter 解析器](#treesitter-解析器)
- [故障排查](#故障排查)
- [本版改动](#本版改动)
- [验证清单](#验证清单)

## 要求

| 项目 | 说明 |
|---|---|
| Neovim | **0.12+**（`nvim --version`），低于 0.12 会直接停止加载 |
| git | vim.pack 安装插件必需 |
| 推荐 | `ripgrep` / `fd`（查找更快）、`latexmk`（LaTeX）、各语言 LSP |
| 可选 | Nerd Font 不需要（状态栏已关闭图标）；GUI 推荐 Neovide |

## 安装

```sh
# 先备份旧配置
mv ~/.config/nvim ~/.config/nvim.bak
mkdir -p ~/.config/nvim
cp init.lua ~/.config/nvim/

# 国内网络（可选，第三方镜像服务）
export NVIM_PACK_MIRROR=https://ghfast.top/

nvim                    # 首次启动会自动安装插件
# 或者无界面预装（服务器 / CI）：
nvim --headless +qa
```

插件版本记录在 `~/.config/nvim/nvim-pack-lock.json`。分享配置时，请把它和 `init.lua` 一起提交。

如果旧版配置用过 `~/.local/share/nvim/site/pack/plugins`，启动时会提示你删除它，否则插件会被重复加载。

## 插件

| 插件 | 用途 |
|---|---|
| [mini.nvim](https://github.com/nvim-mini/mini.nvim) | 用到的模块：notify、starter、pairs、ai、statusline、bufremove、git、diff、pick、extra、surround、clue |
| [multicursor.nvim](https://github.com/jake-stewart/multicursor.nvim) | 多光标（`1.0` 分支），只用 `Q` / `gQ` |
| [overseer.nvim](https://github.com/stevearc/overseer.nvim) | 任务运行器（make / npm / cargo / tasks.json …） |

## 个人设置 USER

`init.lua` 开头的 `USER` 表。一般只需要改这里：

| 键 | 默认 | 说明 |
|---|---|---|
| `author` | `nil` | F12 文件头作者，nil 时读取 `git config user.name` |
| `mirror` | `$NVIM_PACK_MIRROR` | GitHub 镜像 |
| `colorscheme` / `background` | `retrobox` / `dark` | 配色（F9 切换深 / 浅色） |
| `font` / `font_size` | `Hack` / 14 | Neovide 字体 |
| `indent` | 4 | 缩进宽度 |
| `width` | 80 | 参考线在第 81 列；F11 / F12 装饰线宽度 |
| `clipboard` | `unnamedplus` | 设为 `""` 则不与系统剪贴板同步 |
| `auto_cd` | true | 自动切换到项目根目录 |
| `root_markers` | 见文件 | 判断项目根目录的标记文件，同一个 `{}` 内的标记优先级相同 |
| `trim_on_save` | true | 保存时去掉行尾空白 |
| `ui2` | true | 0.12 实验性的新消息 / 命令行界面 |
| `autocomplete` | true | 0.12 原生自动补全 |
| `inlay_hints` | false | LSP 内联类型提示 |
| `latex_engine` | `-xelatex` | latexmk 引擎 |
| `pdf_viewers` | okular / evince / zathura | 按顺序尝试 |
| `bigfile_mb` | 5 | 超过这个大小的文件启用降级模式 |

## 键位

`<Space>` 是 Leader。按下 `<Space>`、`g`、`z`、`[`、`]`、`'`、`` ` ``、`"`、`<C-w>`（以及插入模式的 `<C-r>` / `<C-x>`）后停顿 0.3 秒，会弹出按键提示。

### 文件 / 查找 / 缓冲区

| 键 | 功能 |
|---|---|
| `<C-s>` | 保存（普通 / 可视 / 插入模式都可用，无改动时不写盘） |
| `<Space>w` / `<Space>q` | 写入 / 退出 |
| `<Space>bd` | 关闭缓冲区，保留窗口布局 |
| `-` | 用 netrw 浏览当前目录 |
| `<Space>ff` `fg` `fb` `fo` `fh` | 查找文件 / 全文搜索 / 缓冲区 / 最近文件 / 帮助 |
| `<Space>fl` `fd` `fr` | 当前文件的行 / 诊断 / 恢复上次查找 |
| `<Space>cd` | 切到文件所在目录，并暂停自动切换 |
| `<Space>cr` | 回到项目根目录，并恢复自动切换 |

### 包围 / 文本对象

| 键 | 功能 |
|---|---|
| `ysiw"` / `yss)` | 给单词加 `"` / 给整行加括号 |
| 可视模式 `S(` | 给选区加括号 |
| `ds(` / `cs"'` | 删除包围 / 把 `"` 换成 `'` |
| `ysiwt` / `ysiwf` | 加标签 / 加函数调用 |
| `vif` `via` `vit` `viq` | mini.ai 文本对象：函数调用 / 参数 / 标签 / 引号 |

### 多光标

基于 multicursor.nvim，**只用 `Q` / `gQ`**，和 Neovim 0.13 自带多光标的默认键一致，升级后手感不变。不占用任何 `<Space>`、Ctrl 或 Alt 组合。

| 键 | 功能 |
|---|---|
| `Q` | 在主光标处放置 / 删除光标，同时暂停其他光标 |
| `5Q` | 在接下来 5 个搜索匹配处加光标（先 `/pattern` 或 `*`） |
| 可视模式 `Q` | 放置 / 删除光标 |
| `gQ` | 找回刚清除的光标 |
| `<Esc>`（有多光标时） | 光标被暂停时恢复，否则清除所有光标 |

**用 Q 逐个放光标：**

1. 移到第一处，按 `Q`。
2. 移到第二处，再按 `Q`（这时只有主光标在动，其他光标是暂停的）。
3. 都放好后按 `<Esc>`，所有光标恢复活动，开始编辑。
4. 编辑完按 `<Esc>` 清除光标。

**常见用法：**

- 连续几行加光标：`Q` `j` `Q` `j` `Q`……然后 `<Esc>`。
- 改某个词出现的几处：`*` 或 `/word` 搜索，再按 `3Q` 在后 3 处加光标，然后编辑。

**和原生键的差别：**

- **`Q` 不再重放宏**，改用 `@@`。`@@` 重复的是「上一次执行的」寄存器，录完宏后第一次要用 `@q`。0.13 自带的 `Q` 也同样不再重放宏。
- **0.12 的 `gQ`（Ex 模式）不再可用**。0.13 里 Ex 模式改用 `:exmode`。
- `ga`、`<C-n>`、`<C-p>`、可视模式 `I` / `A` / `s` 都保持 Neovim 原本的功能。

**关于 Neovim 0.13：** 0.13 自带多光标，`Q` 添加 / 删除，`[count]Q` 在搜索匹配处加光标，`gQ` 找回，`<C-LeftMouse>` 鼠标切换，`<C-l>` 清除，`q=` 跟随模式。这份配置在 0.13 上：

- 用 multicursor.nvim 的 `Q` / `gQ` 盖掉自带的同名键；
- 把 `<C-LeftMouse>` 改回普通点击；
- `<C-l>` 本来就是切换窗口；

所以始终只有一套多光标在工作。以后想改用 0.13 自带的多光标：删掉 `init.lua` 里 PLUGINS 中的 multicursor.nvim 和第 4 节，运行 `:PackClean`。键还是 `Q` / `gQ`，不用重新适应。

### 任务 / LaTeX

| 键 | 功能 |
|---|---|
| `<Space>or` `oo` `ol` | 运行任务 / 任务面板 / 重跑最近任务 |
| `<Space>oa` `os` | 对任务执行操作（重启 / 停止 / 看输出） / 把 shell 命令作为任务运行 |
| `<Space>tt` `tw` | 编译 / 持续编译（`-pvc`，用 `<Space>oa` 停止） |
| `<Space>te` `tc` `tv` | 完全重建 / 清理辅助文件（保留 PDF） / 打开 PDF |

### LSP / 诊断 / Git

除 `gd`、`<Space>cf`、`<M-s>` 外，下表的 LSP 键都是 Neovim 内置的默认键：

| 键 | 功能 |
|---|---|
| `gd` / `K` | 跳到定义 / 悬停文档 |
| `grn` / `gra` | 重命名 / 代码操作 |
| `grr` / `gri` / `grt` / `gO` | 引用 / 实现 / 类型定义 / 符号列表 |
| `<C-]>` | 跳到定义（LSP 设置了 tagfunc） |
| `<Space>cf` | 格式化（可视模式下只格式化选区） |
| 插入模式 `<M-s>` | 签名帮助（内置的插入模式 `<C-s>` 已被"保存"占用） |
| `[d` `]d` / `[D` `]D` | 上 / 下一个诊断，跳转后自动弹窗 / 第一个、最后一个诊断 |
| `<C-w>d` | 在浮窗里显示光标处的诊断 |
| `]h` `[h` | 下 / 上一个修改块 |
| `ghgh` / `gHgh` | 暂存 / 撤销光标处的修改块（可视模式用 `gh` / `gH`） |
| `<Space>go` / `<Space>gs` | 显示差异 / 光标处的提交信息 |

### 开关 / 编辑 / 其他

| 键 | 功能 |
|---|---|
| `<Space>uu` | 撤销树（内置 `:Undotree`） |
| `<Space>uh` | 切换 LSP 内联提示 |
| `<Space>uw` | 当前缓冲区保存时是否去掉行尾空白 |
| `F9` / `F10` | 深浅色 / 拼写检查（已设 `cjk`，中文不会被标红） |
| `F11` / `F12` | 注释分隔线 / 文件头（会自动跳过 shebang 和 `<?xml`） |
| `gc` / `gcc` | 注释（内置） |
| `<M-j>` / `<M-k>` | 上下移动行 |
| `<C-h/j/k/l>` | 切换窗口 |
| `\` | 替换光标下的单词（逐个确认） |
| `<Esc>` | 清除搜索高亮（有多光标时改为恢复 / 清除光标） |
| `@@` | 重放上一次执行的宏（`Q` 已用于多光标） |
| `<C-z>` | 进入命令行（占用了挂起功能，需要挂起请用 `:suspend`） |
| 终端 `<Esc><Esc>` | 回到普通模式 |
| 插入 `<M-d>` | 插入当前时间 |
| 插入 `<M-=>` / `<M-->` | 在行尾补 `;` 或 `:` 并换行 |
| 插入 `<C-BS>` / `<C-Del>` | 删除前 / 后一个词 |
| `<Tab>` | 依次尝试：片段跳转 → 菜单下一项 → 缩进 → LSP 补全 / 关键字补全 |
| Neovide `<C-=>` `<C-->` `<C-0>` | 放大 / 缩小 / 重置字体 |

## 功能说明

### 补全

- **插入模式：** 没有 LSP 的缓冲区用 0.12 原生的 `'autocomplete'`，打字时自动弹出关键字补全。挂上 LSP 后，该缓冲区的原生自动补全会关掉，改由 `vim.lsp.completion` 自动触发，同时支持片段展开。
  - 如果你的 0.12 构建里 `'autocomplete'` 只是全局选项、不能按缓冲区关闭，LSP 补全会改为用 `<Tab>` 手动触发，不会同时弹出两个菜单。
- **命令行：** 在 `:`、`/`、`?` 里边输入边弹出补全菜单（`wildtrigger()`）。菜单打开时 `<Up>` / `<Down>` 仍然用来翻命令历史，`<Tab>` 选择补全项。

### ui2（实验性）

启用后没有 "Press ENTER" 提示，命令行会随输入高亮，`:messages` 用可滚动的窗口显示。如果遇到兼容问题，把 `USER.ui2` 设为 `false`。

### 保存时去掉行尾空白

默认开启，以下情况会跳过：

- markdown / diff 文件（markdown 行尾两个空格表示换行）
- 二进制文件、大文件
- 项目的 `.editorconfig` 写了 `trim_trailing_whitespace = false`
- 用 `<Space>uw` 关掉了当前缓冲区
- 全局关闭：把 `USER.trim_on_save` 设为 `false`

### 项目根目录

打开文件时自动 `cd` 到项目根目录，Overseer 和查找都以它为准。`Makefile` / `package.json` / `Cargo.toml` 等标记优先于 `.git`，所以在 monorepo 的子包里会停在子包目录。家目录本身是 dotfiles 仓库时不会切到 `~`。

### 大文件（> `bigfile_mb`）

以下功能会关掉：treesitter 和 syntax 高亮、折叠（改为手动）、十字光标线、LSP、mini.diff、undo 文件、swap 文件、保存时去行尾空白。

### 折叠

默认按缩进折叠。有 treesitter 解析器时用 treesitter 折叠；没有解析器但 LSP 支持 foldingRange 时，用 LSP 折叠。打开文件时默认全部展开（`foldlevel=99`）。

### LaTeX

- 编译参数：`-synctex=1 -file-line-error -interaction=nonstopmode -halt-on-error`。
- 用 Overseer 编译失败时，会自动打开 quickfix 并列出错误。
- 正向 / 反向搜索：已生成 synctex 文件。以 zathura 为例，想实现反向搜索（在 PDF 里点击跳回源码），可以用 `nvim --listen /tmp/nvim.sock` 启动，再在 zathura 里配置：
  ```
  set synctex-editor-command "nvim --server /tmp/nvim.sock --remote-send '<C-\\><C-n>:e %{input}<CR>:%{line}<CR>'"
  ```
  (具体语法以 zathura 文档为准)

### Overseer

所有任务在启动和结束时都会弹出通知。Neovim 窗口不在前台时，结束通知还会以桌面通知发出。

## 命令

| 命令 | 说明 |
|---|---|
| `:PackUpdate [名字…]` | 检查更新（支持 Tab 补全插件名）。确认页里 `:write` 应用，`:quit` 放弃，之后 `:restart` |
| `:PackSync` | 把插件恢复到锁文件记录的版本（换机器 / 回滚时用） |
| `:PackClean` | 删除不在 PLUGINS 列表里的插件 |
| `:restart` | 重启 Neovim（0.12 内置） |
| `:Undotree` | 撤销树（`<Space>uu`） |
| `:DiffTool dir1 dir2` | 对比两个目录 / 文件（0.12 内置 `nvim.difftool`） |
| `:lsp` | 交互式地查看、重启、停止 LSP 客户端 |
| `:checkhealth vim.lsp vim.pack` | 自检 |
| `:lua MiniNotify.show_history()` | 通知历史 |

## LSP 服务器安装

没安装的服务器会被自动跳过。要新增服务器，在 `init.lua` 第 9 节的 `servers` 表里加一项即可。

| 服务器 | 语言 | 安装示例 |
|---|---|---|
| basedpyright | Python | `pipx install basedpyright` |
| lua_ls | Lua | 包管理器安装 `lua-language-server` |
| bashls | Bash | `npm i -g bash-language-server` |
| dartls | Dart | 随 Dart / Flutter SDK 附带 |

## Treesitter 解析器

Neovim 自带的解析器只有 c、lua、markdown、vim、vimdoc、query 这几种，其他语言默认用传统的正则高亮。要为更多语言启用 treesitter 高亮和折叠，可以用以下任一方式：

- 安装 [nvim-treesitter](https://github.com/nvim-treesitter/nvim-treesitter) 的 `main` 分支（需要 `tree-sitter` CLI），在 PLUGINS 里加上它，然后 `:TSInstall python bash latex …`；
- 或者手动把 `python.so` 放进 `~/.local/share/nvim/site/parser/`，并把对应的 queries 放进 `site/queries/python/`。

装好解析器后，配置会自动启用对应语言的 treesitter，不需要再改配置。

## 故障排查

| 现象 | 处理 |
|---|---|
| 启动时提示有插件未加载 | 检查 git 和网络；国内网络请设置 `NVIM_PACK_MIRROR`；然后重启 |
| 插件目录里只有 `.git`，内容是空的 | 配置会自动删掉这种目录，重启后重新安装 |
| 界面 / 消息显示异常 | 把 `USER.ui2` 设为 `false` |
| 补全菜单同时弹出两个，或输入的字符被吞掉 | 把 `USER.autocomplete` 设为 `false` |
| `Q` 的行为不对，或 `:verbose nmap Q` 显示不是 multicursor | 有别的插件或配置在之后又映射了 `Q`。`:verbose nmap Q` 会显示最后是在哪里定义的，去掉那一处即可 |
| `5Q` 提示"还没有搜索过" | 先用 `/pattern` 或 `*` 搜索，再按 `[count]Q` |
| Big5 文件显示乱码 | `:e ++enc=big5` |
| LSP 没有启动 | `:checkhealth vim.lsp`；确认服务器命令在 `$PATH` 里 |

## 本版改动

**修复**

- `[d` / `]d` 不再使用已弃用的 `float` 参数。自己写的映射已删除，改为内置键加 `diagnostic.config({ jump = { on_jump } })`。
- `switchbuf` 改成 `useopen,uselast`，quickfix 和跳转不会再不停开新标签页。
- `C` 还给内置命令（`c$`）。
- 删除所有 `<C-g>` 取消映射，恢复搜索时的 `<C-g>` / `<C-t>`、插入模式的 `<C-g>u` 等内置功能。
- `<Tab>` 不再盲目调用 omnifunc，只在有 LSP 时触发 LSP 补全。
- 去行尾空白会遵守 EditorConfig，并可以按缓冲区开关。
- 大文件额外关掉 LSP、折叠和十字光标线。
- `<Space>cd` 不再和自动 cd 冲突，新增 `<Space>cr`；`root_markers` 改为子包优先。
- `fileencodings` 改成 `gb18030`；`spelllang` 加上 `cjk`；参考线改为固定在 `width + 1` 列。

**整理**

- 删除：`showmatch` / `matchtime`、`smartindent`、`extends:#`、多余的 netrw 选项、`<Space>rn` / `<Space>ca`（改用内置 `grn` / `gra`）。
- 简化了 `pick_tool`；mini.clue 补全了所有分组。
- **多光标只用 `Q` / `gQ`**，与 Neovim 0.13 内置多光标同键。删除了 `<Space>m` 分组及其下所有键，以及 `<C-q>`、`<C-Down>` / `<C-Up>`、`<C-n>` / `<C-p>`、`<M-n>` / `<M-p>`、`ga`、可视模式 `s` / `<M-s>` / `I` / `A`、鼠标键和多光标时的 `(` `)` `<M-,>` `,` `&` `<M-(>` `<M-)>`。`ga`、`<C-n>` / `<C-p>`、可视 `I` / `A` / `s` 恢复为原生功能。

**新增**

- 0.12 功能：ui2、原生自动补全、命令行 `wildtrigger()`、`nvim.undotree`、`nvim.difftool`、`pumborder`、treesitter / LSP 折叠、inlay hints 开关、linked editing、CodeLens。
- 其他：`:PackSync`、`:PackUpdate` 插件名补全、`<Space>bd`、`<Space>cf`、插入模式 `<M-s>`、终端 `<Esc><Esc>`、LaTeX 的 synctex / quickfix / 持续编译、Overseer 桌面通知、mini.clue 的标记 / 寄存器 / 补全提示。

## 验证清单

以下几项用到了 0.12 较新或实验性的接口，都做了保护，失败只会跳过该功能。第一次使用时建议逐项确认一下：

- [ ] 插入模式打字时有补全弹出；在有 LSP 的文件里，菜单里出现的是 LSP 的补全项
- [ ] 输入 `:e ` 时自动弹出文件补全
- [ ] `<Space>uu` 能打开撤销树
- [ ] `<Space>tt` 编译出错时，quickfix 能自动打开（如果 Overseer 报组件参数错误，删掉 `open_on_exit` / `items_only` 这两个参数）
- [ ] `:checkhealth vim.lsp vim.pack` 没有 deprecated 警告
- [ ] `:verbose nmap Q` 显示来自 `init.lua` 的 multicursor 映射；按 `Q` 能放置光标，`<Esc>` 能恢复 / 清除
