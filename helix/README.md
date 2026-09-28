# Helix 配置（Helix 25.07+）

配置文件是 `~/.config/helix/config.toml`，和 Neovim 0.12 配置共用一套按键习惯。

**原则：**
- 能用 Helix 原生键就用原生键，只在"和 Neovim 同一个键做同一件事"时才改键；
- 不追求复刻 Neovim。Helix 做不到或做起来别扭的功能，直接放弃。

## 目录
- [要求与安装](#要求与安装)
- [键位](#键位)
- [与 Neovim 的对应](#与-neovim-的对应)
- [功能说明](#功能说明)
- [languages.toml 建议](#languagestoml-建议)
- [较新版本可开启的选项](#较新版本可开启的选项)
- [相对旧配置的变化](#相对旧配置的变化)
- [故障排查](#故障排查)
- [验证清单](#验证清单)

## 要求与安装

| 项目 | 说明 |
|---|---|
| Helix | **25.07+**（`hx --version`）。LaTeX 命令用到的变量展开 `%{buffer_name}`、宏绑定、`-` 目录浏览器都依赖 25.07 |
| 终端 | 需要把 Alt/Option 当作 Meta 发送（`A-j` `A-k` `A-d` 才能用） |
| 推荐 | `ripgrep`，各语言 LSP（`hx --health` 查看），`latexmk` |
| 剪贴板 | Linux 需要 `wl-clipboard` 或 `xclip`/`xsel`；SSH 下可设置 `clipboard-provider = "termcode"` |

```sh
cp config.toml ~/.config/helix/config.toml
hx --health            # 检查剪贴板、LSP、tree-sitter
```

修改配置后，在 Helix 里执行 `:config-reload` 即可生效，不用重启。

## 键位

`<Space>` 是 Leader，按下后停顿会弹出按键提示。**原生**表示这是 Helix 自带的键，配置里没有改。

### 文件 / 查找

| 键 | 功能 |
|---|---|
| `C-s` | 保存（`:update`，没改动就不写盘）；插入 / 选择模式下保存后回到普通模式 |
| `<Space>w` / `<Space>q` | 写入 / 退出 |
| `-` | 打开当前文件所在目录的浏览器（回车进入子目录或打开文件） |
| `<Space>ff` `fg` `fb` | 文件 / 全文搜索 / 缓冲区 |
| `<Space>fd` `fD` | 当前文件诊断 / 整个项目诊断 |
| `<Space>fr` `fj` | 重新打开上一个选择器 / 跳转历史 |
| `<Space>fh` | 命令面板（可以按名字搜索所有命令和对应的键） |
| `<Space>f.` / `fs` | 在当前文件目录里找文件 / 保存 |
| 原生 `<Space>F` `e` `E` `/` | 在 cwd 找文件 / 文件浏览器 / 全文搜索 |

### 缓冲区 / 窗口

| 键 | 功能 |
|---|---|
| `<Space>bb` / `<Space><Tab>` | 缓冲区列表 |
| `<Space>bd` `bn` `bp` | 关闭 / 下一个 / 上一个（原生 `gn` `gp` 也可以切换） |
| `C-h/j/k/l` | 切换窗口 |
| 原生 `C-w v` `C-w s` `C-w q` `C-w o` | 垂直分屏 / 水平分屏 / 关闭窗口 / 只保留当前窗口（和 Vim 相同） |

### LSP / 诊断 / Git

| 键 | 功能 |
|---|---|
| 原生 `gd` `gr` `gi` `gy` `gD` | 定义 / 引用 / 实现 / 类型定义 / 声明 |
| `K`（原生 `<Space>k`） | 悬停文档 |
| `<Space>ca` `cr` `cf` `ce` | 代码操作 / 重命名 / 格式化 / 诊断列表 |
| 原生 `<Space>a` `r` `s` `S` `d` | 代码操作 / 重命名 / 文件符号 / 项目符号 / 诊断 |
| 原生 `[d` `]d` `[D` `]D` | 上一个、下一个 / 第一个、最后一个诊断 |
| 原生 `]g` `[g` | 下 / 上一个 Git 修改块 |
| `:reset-diff-change` | 撤销光标处的修改块 |

### 多光标（全是原生键）

| 键 | 功能 |
|---|---|
| `C-Down` / `C-Up`（原生 `C` / `A-C`） | 在下方 / 上方加光标 |
| `\` | 选中全文所有"光标下的词"，接着按 `c` 统一修改 |
| 原生 `*` → `n` | 把光标词设为搜索词，逐个跳转；选择模式（`v`）下按 `n` 会逐个加入选区 |
| 原生 `s` / `S` | 在选区内按正则选中 / 按正则拆分 |
| 原生 `,` `(` `)` `&` `A-,` | 只留主光标 / 切换主光标 / 对齐 / 去掉主光标 |
| `Esc` | 收起选区，回到单光标 |

### 编辑

| 键 | 功能 |
|---|---|
| `gc` | 注释 / 取消注释（原生 `C-c` 也可以） |
| `A-j` / `A-k` | 上下移动行，选中多行时整块移动 |
| 原生 `ms"` `mr"'` `md"` | 加包围 / 替换包围 / 删除包围 |
| 原生 `miw` `maf` `mia` | 文本对象：词 / 函数 / 参数（需要 tree-sitter） |
| 插入 `C-a` `C-e` `C-h` `C-l` | 行首 / 行尾 / 左移 / 右移 |
| 插入 `A-d` | 插入当前时间 `YYYY-MM-DD HH:MM:SS` |
| 原生插入 `C-w` / `A-Backspace` | 删除前一个词 |

### 开关（`<Space>u`）

| 键 | 功能 |
|---|---|
| `<Space>uw` | 保存时去行尾空白 |
| `<Space>uh` | LSP 内联提示 |
| `<Space>us` | 软换行 |
| `<Space>un` | 相对 / 绝对行号 |

这些开关在重启或 `:config-reload` 后会恢复成配置里的值。任何布尔选项都可以用 `:toggle 选项名` 临时切换。

### LaTeX（`<Space>t`）

| 键 | 功能 |
|---|---|
| `<Space>tt` | 保存并编译，只显示报错行和 latexmk 的结论 |
| `<Space>te` | 完全重建（`-gg`） |
| `<Space>tw` / `<Space>tk` | 后台持续编译（`-pvc`，文件一保存就重新编译）/ 停止 |
| `<Space>tc` | 清理辅助文件，保留 PDF |
| `<Space>tv` | 打开 PDF（Linux 用 `xdg-open`，macOS 用 `open`） |

## 与 Neovim 的对应

| 功能 | Neovim | Helix |
|---|---|---|
| 保存 / 写入 / 退出 | `C-s` / `<Space>w` / `<Space>q` | 相同 |
| 目录浏览 | `-` | 相同 |
| 查找 | `<Space>ff fg fb fd fr` | 相同 |
| 帮助 | `<Space>fh` | `<Space>fh` 命令面板 |
| 缓冲区 | `<Space>bd` | 相同，另有 `bb bn bp` |
| 分屏 | `C-w v/s/c/o` | `C-w v/s/q/o` |
| 格式化 | `<Space>cf` | 相同 |
| 重命名 / 代码操作 | `grn` / `gra` | `<Space>r` / `<Space>a`（或 `<Space>cr` / `ca`） |
| 引用 / 实现 / 类型 | `grr` `gri` `grt` | `gr` `gi` `gy` |
| 修改块 | `]h` `[h` | `]g` `[g` |
| 加光标 | `C-Down` / `C-Up` | 相同 |
| 全部相同词 | `<Space>ma` | `\` |
| 单光标 / 切主光标 / 对齐 | `,` `(` `)` `&` | 相同（Helix 原生） |
| 移动行 | `M-j` / `M-k` | `A-j` / `A-k` |
| 插入时间 | 插入 `M-d` | 插入 `A-d` |
| 开关 | `<Space>uw` `uh` | 相同，另有 `us` `un` |
| LaTeX | `<Space>tt tw te tc tv` | 相同，另有 `tk` 停止 |
| 系统剪贴板 | `clipboard=unnamedplus` | `default-yank-register = "+"` |
| 行内诊断 | `virtual_text` | `end-of-line-diagnostics` + `inline-diagnostics` |

以下 Neovim 功能在 Helix 里没有，或者不值得硬做，所以放弃了：

- 拼写检查（F10）
- 注释分隔线 / 文件头（F11 / F12）
- 撤销树
- Overseer 任务面板
- 自动切换项目根目录（Helix 的 `<Space>f` 本来就以项目根为准）

## 功能说明

### 剪贴板
`default-yank-register = "+"` 让 `y`、`d`、`c`、`p` 都直接使用系统剪贴板，效果和 Neovim 的 `unnamedplus` 一样。`A-j` / `A-k` 通过 `z` 寄存器中转，移动行不会冲掉剪贴板里的内容。

### 保存时去行尾空白
默认开启，`<Space>uw` 可以临时关闭。和 Neovim 不同，Helix 的这个选项是全局的，**不能单独对 markdown 关闭**。写 markdown 需要硬换行时，可以：
- 行尾用 `\` 代替两个空格（CommonMark 标准写法）；
- 或者临时 `<Space>uw` 关掉。

较新版本的 Helix 支持 EditorConfig。开启后，项目里 `.editorconfig` 的 `trim_trailing_whitespace` 设置会优先于这里。

### 诊断显示
- 光标所在行：warning 及以上的诊断在行内完整显示；
- 其他行：诊断显示在行尾；
- 查看全部：`<Space>fd`。

### LaTeX
- 编译参数：`-xelatex -synctex=1 -file-line-error -interaction=nonstopmode -halt-on-error`，加上 `-cd`，所以在任何工作目录下都能编译当前 tex 文件。
- 输出用 `grep` 过滤，只保留 `文件:行号:` 形式的报错和 `Latexmk:` 开头的结论。要看完整日志，请打开 `.log` 文件。
- 持续编译在后台运行。退出 Helix 后它**仍会继续运行**，需要 `<Space>tk` 或 `pkill latexmk` 手动停止。
- 这些命令对当前缓冲区直接执行，**不会检查它是不是 .tex 文件**。
- 如果想让 LSP 也能编译 / 预览，可以配置 texlab（Helix 内置了它的服务器定义）。

## languages.toml 建议

在 `~/.config/helix/languages.toml` 里写入（可选）。这是为了和 Neovim 用同一个 Python LSP：

```toml
# Python：basedpyright + ruff（和 Neovim 一样用 basedpyright）
[language-server.basedpyright]
command = "basedpyright-langserver"
args    = ["--stdio"]

[[language]]
name = "python"
language-servers = ["basedpyright", "ruff"]
```

用 `hx --health python` 确认 LSP 已被识别。

## 较新版本可开启的选项

下面这些选项只在 Helix 开发版文档里看到过。Helix 遇到不认识的配置项会报错，所以配置里先把它们注释掉了。升级后如果 `:config-reload` 不报错，就可以打开：

| 选项 | 作用 |
|---|---|
| `[theme] dark = … / light = …` | 跟随终端深浅色切换主题（相当于 Neovim 的 F9） |
| `editor-config = true` | 遵守 `.editorconfig` |
| `[editor.whitespace.render] trailing = "all"` | 只显示行尾空格 |

## 相对旧配置的变化

| 旧配置 | 现在 | 原因 |
|---|---|---|
| `C-g` 取消（三种模式） | 删除，统一用 `Esc` | 和 Neovim 一致 |
| `<Space>/` 清除选区 | 恢复原生全文搜索 | 普通模式 `Esc` / 原生 `;` 就能收起选区 |
| `<Space>w v/s/c/d…` 窗口菜单 | `<Space>w` 改为保存；分屏用 `C-w` | 和 Neovim 一致；`C-w` 本来就和 Vim 相同 |
| `<Space>s s/p/g` | 恢复原生 `<Space>s` / `S` / `/` | 原生键更短 |
| `<Space>rn` | 恢复原生 `<Space>r` | Neovim 那边也去掉了 `rn` |
| `<Space>e` 诊断 | 恢复原生文件浏览器；诊断用 `<Space>d` / `fd` / `ce` | 恢复原生功能 |
| `<Space>cd/ci/co` | 删除 | 和 `gd` / `gi` / `gr` 重复 |
| `A-j` / `A-k` 会覆盖寄存器 | 改成经 `z` 寄存器中转的宏 | 不冲掉剪贴板 |
| `<Space>tt` 不带文件名、不先保存 | 先保存，带上 `%{buffer_name}`，过滤输出 | 能用了 |
| `C-s` 用 `:w` | 改用 `:update` | 没改动时不写盘 |
| 新增 | `-` 目录浏览器、`C-Down`/`C-Up`、`\`、`<Space>u` 开关、`<Space>cf`、`fd fD fr fj fh f.`、`tw tk te tv`、插入 `A-d`、剪贴板、去行尾空白、行内诊断、十字光标线、弹窗边框、状态栏 Git 分支 | |

## 故障排查

| 现象 | 处理 |
|---|---|
| 启动时提示配置错误，按键全变回默认 | 版本太旧或选项名不对；`hx --version` 确认 ≥ 25.07，按提示删掉或注释报错的那一行 |
| `A-j` 等 Alt 键没反应 | 终端设置里开启"Option / Alt 作为 Meta" |
| `C-Down` / `C-Up` 没反应 | 被系统占用（macOS 的调度中心），可改用原生 `C` / `A-C` |
| 复制不到系统剪贴板 | `hx --health` 查看 clipboard 一项；SSH 下可设 `clipboard-provider = "termcode"` |
| LSP 没启动 | `hx --health <语言>`；`:log-open` 查看日志 |
| markdown 行尾两个空格被删 | 见"保存时去行尾空白"一节 |

## 验证清单

- [ ] `\`：光标放在一个词上按 `\`，全文相同的词都被选中。如果弹出了正则输入框却什么都没选中，说明"输入框为空时回车沿用上次搜索"这个行为不成立，请手动按 `*`、`%`、`s`、`Enter`。
- [ ] 插入模式 `A-d`：时间插入后光标的位置是否顺手。如果时间被选中，或者光标停在时间前面，可以把这个键改成 `:append-output`。
- [ ] `<Space>un`：能在相对行号和绝对行号之间切换。如果报错，改成 `:set line-number absolute`。
- [ ] `A-j` / `A-k`：在文件首行、末行、多行选区上移动都正常。
- [ ] `<Space>tt`：故意写错一行，能看到 `main.tex:12: …` 这样的报错。
