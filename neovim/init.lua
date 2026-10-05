-- Neovim 0.12+ 单文件配置 ~/.config/nvim/init.lua — Windows: %LOCALAPPDATA%\nvim\init.lua
--
-- 设计原则：默认键优先，少量例外有明确理由
--   · Neovim 内置的导航 / LSP / 编辑键（gr* K [d ]d gcc <C-l> an/in …）不覆盖
--   · Q/gQ、- 等兼容键只为 0.12 模拟 0.13 行为；保存、折行等少数人体工学键另行说明
--   · 工作流键主要放在 <Leader>（空格）下，按功能分组：b c e f g o p t u
--   · 只在某种文件里有用的键（LaTeX / Python / Go）只在该文件类型的缓冲区里生效
--
-- ╔══════════════════════════════ PLUGINS ══════════════════════════════════
-- ║ mini.nvim / overseer.nvim（0.12 另加 multicursor.nvim；0.13+ 用内置多光标）
-- ║ 首次启动由内置 vim.pack 自动安装（需要 git）；版本记录在 nvim-pack-lock.json
-- ║ 任一插件缺失时自动跳过相关功能，启动后汇总提示一次
-- ║ 国内网络: export NVIM_PACK_MIRROR=https://ghfast.top/    预装: nvim --headless +qa
-- ║   Windows: setx NVIM_PACK_MIRROR https://ghfast.top/  （设置后重开终端）
-- ║ :PackUpdate [名字…]   :PackSync 按锁文件同步   :PackClean 删除不用的插件   :restart 重启
-- ╚═════════════════════════════════════════════════════════════════════════
--
-- ╔══════════════════════════════ CHEATSHEET ══════════════════════════════
-- ║ 内置（不需要配置，记住即可）
-- ║   LSP   K 文档  grn 重命名  gra 代码操作  grr 引用  gri 实现  grt 类型定义  gO 符号  grx CodeLens
-- ║         <C-]> 定义   插入 <M-s> 签名帮助   gq{motion} 用 LSP 格式化
-- ║   诊断  [d ]d 上/下一个（本配置跳转后自动弹窗）  [D ]D 首/尾  <C-w>d 浮窗
-- ║   列表  [q ]q quickfix  [l ]l loclist  [b ]b 缓冲区  [t ]t 标签  [<Space> ]<Space> 插空行
-- ║   编辑  gcc/gc 注释  gx 打开链接  可视 an/in 扩大/缩小语法选区  <C-l> 清高亮(0.13 也清多光标)
-- ║   补全  <C-n>/<C-p> 选择  <C-y> 确认  <C-e> 取消  <C-x><C-o> 手动 LSP 补全  <Tab>/<S-Tab> 片段跳转
-- ║   多光标 Q 放置/删除  5Q 后 5 个搜索匹配  gQ 找回  <C-LeftMouse> 鼠标  <C-l> 清除（0.12 由插件模拟）
-- ║   宏    q{reg} 录制  @{reg} 执行  @@ 重复（Q 已归多光标）
-- ║   目录  - 打开上级目录（0.13 内置 dir；0.12 由本配置用 netrw 模拟）
-- ╟─ 插件默认键 ────────────────────────────────────────────────────────────
-- ║   mini.surround(vim-surround 风格) ysiw" yss) 可视 S( ds( cs"'    mini.move <M-h/j/k/l>
-- ║   mini.diff ]h [h 修改块  gh{motion}/ghgh 暂存  gH{motion}/gHgh 撤销    mini.ai f a t q b B I L N D
-- ╟─ <Leader> 自定义键 ─────────────────────────────────────────────────────
-- ║   <Space>e 文件管理器  bd 关缓冲区  cf 格式化
-- ║   <Space>f  f 文件 g 全文 w 光标词 b 缓冲区 o 最近 h 帮助 l 本文件行 d 诊断 s 符号 k 快捷键 r 恢复
-- ║             v 项目访问记录 V 全局访问记录 S/R/W/D 会话选择/恢复/保存/删除
-- ║   <Space>g  o 差异叠加  s 光标处提交
-- ║   <Space>o  r 运行任务 o 面板 l 重跑 a 操作 s shell 命令
-- ║   <Space>u  u 撤销树 h 内联提示 d 诊断展开 w 去行尾空白 f Python格式化 G Go格式化 s 拼写
-- ║   .tex 内  <Space>t  t 编译 w 持续 e 重建 c 清理 v 看 PDF
-- ║   .py  内  <Space>p  r 运行 a 带参数 w 保存即重跑 d 终端/pdb b breakpoint() t/f/T 测试
-- ║                      i 整理 import x ruff 修复 v 选解释器 p REPL s 发送行/选区
-- ║   .go  内  <Space>g  r 运行 t/f/T 测试 b 构建 F 格式化 i 整理 import
-- ╟─ 命令 ──────────────────────────────────────────────────────────────────
-- ║   :CommentRule 分隔线  :FileHeader 文件头  :CdHere 切到文件目录  :CdRoot 回项目根
-- ║   :Undotree  :DiffTool a b  :lsp  :checkhealth vim.lsp vim.pack
-- ╚════════════════════════════════════════════════════════════════════════

if vim.fn.has("nvim-0.12") == 0 then
  vim.api.nvim_echo({ { "此配置需要 Neovim 0.12+，已停止加载", "ErrorMsg" } }, true, {})
  return
end

----------------------------------------------------------------------
-- 个人设置：别人使用这份配置时，通常只需要改这里
----------------------------------------------------------------------
local USER = {
  author       = nil,                        -- :FileHeader 作者；nil = 自动读取 git config user.name
  mirror       = vim.env.NVIM_PACK_MIRROR,   -- GitHub 镜像，例 "https://ghfast.top/"；nil = 直连
  colorscheme  = "retrobox",                 -- 内置备选: default / habamax / unokai
  background   = "dark",                     -- "dark" / "light"（F10 临时切换）
  font         = "Hack,Consolas",            -- [Win] GUI（Neovide）字体，逗号后为回退字体
  font_size    = 14,
  indent       = 4,                          -- 缩进宽度（空格）
  width        = 90,                         -- 参考线位置(第 width+1 列) 与 :CommentRule/:FileHeader 宽度
  clipboard    = "unnamedplus",              -- 与系统剪贴板同步；设为 "" 则不同步
  auto_cd      = true,                       -- 打开文件时自动切换到项目根目录
  -- 项目根标记：同一层 { } 内优先级相同（取最近的），monorepo 子包优先于 .git
  root_markers = { { "Makefile", "justfile", "package.json", "pyproject.toml",
                     "Cargo.toml", "pubspec.yaml", "go.work", "go.mod" }, ".git", ".vscode" },
  trim_on_save = true,                       -- 保存时去行尾空白（<Space>uw 按缓冲区切换）
  ui2          = true,                       -- 0.12 实验性新消息/命令行界面（无 Press ENTER）
  autocomplete = true,                       -- 边输入边弹补全（无 LSP 用原生，有 LSP 用 LSP）
  inlay_hints  = false,                      -- LSP 内联类型提示默认开关（<Space>uh 切换）
  native_multicursor = true,                 -- 0.13+ 用内置多光标（同为 Q/gQ）；false = 继续用插件
  latex_engine = "-xelatex",                 -- latexmk 引擎: -xelatex / -lualatex / -pdf
  -- 按顺序尝试，都没有就用系统默认程序；[Win] Windows 上会再自动尝试 SumatraPDF
  pdf_viewers  = { "okular", "evince", "zathura" },
  bigfile_mb   = 5,                          -- 超过此大小：关高亮 / 折叠 / LSP / diff / undo 文件
  -- PATH 里找不到 LSP / ruff 时，再到这些目录找（uv tool / pipx 在 Windows 上也装到 ~/.local/bin）
  -- [Win] 另会自动加入：mason、npm、scoop、winget、pip --user、cargo、conda base 的目录（见第 9 节）
  extra_path   = { "~/.local/bin" },
  python            = nil,                   -- 强制指定解释器路径；nil = 自动探测（见第 9 节）
  py_typecheck      = "standard",            -- basedpyright: off / basic / standard / strict / recommended / all
  py_format_on_save = true,                  -- 有 ruff 时保存自动格式化（<Space>uf 切换）
  py_line_length = 90,                       -- black是88
  go_format_on_save = true,                  -- gopls 保存时格式化（<Space>uG 切换）
}

vim.g.mapleader,vim.g.maplocalleader = " "," "   -- 文件类型专用键用 <LocalLeader>，这里与 <Leader> 相同，按起来一样

local map   = vim.keymap.set
local L     = vim.log.levels
local o     = vim.o
local au    = vim.api.nvim_create_autocmd
local cmd   = vim.api.nvim_create_user_command
local group = vim.api.nvim_create_augroup("UserConfig", { clear = true })
local function has(exe) return vim.fn.executable(exe) == 1 end
-- vim.cmd 是可调用 table，pcall(vim.cmd, …) 会被 lua_ls 报类型错误；用真正的函数
local function try_cmd(c) return pcall(vim.api.nvim_command, c) end

local HAS_013   = vim.fn.has("nvim-0.13") == 1
local NATIVE_MC = HAS_013 and USER.native_multicursor
local IS_WIN    = vim.fn.has("win32") == 1

-- ui2 是实验性 API；保留为可选项，但失败时不影响正常启动。
if USER.ui2 and vim.fn.has("nvim-0.12") == 1 then
  pcall(function() require("vim._core.ui2").enable({}) end)
end

----------------------------------------------------------------------
-- 0. 插件 (vim.pack)
----------------------------------------------------------------------
local PLUGINS = {
  { src = "https://github.com/nvim-mini/mini.nvim" },
  { src = "https://github.com/stevearc/overseer.nvim" },
}
if not NATIVE_MC then   -- 0.13+ 有内置多光标，不再需要插件（旧插件可 :PackClean 删除）
  table.insert(PLUGINS, { src = "https://github.com/jake-stewart/multicursor.nvim", version = "1.0" })
end

local PACK_DIR = vim.fn.stdpath("data") .. "/site/pack/core/opt/"   -- vim.pack 的安装目录
local function pname(spec) return spec.name or (spec.src:gsub("%.git$", "")):match("[^/]+$") end

-- 镜像只在 vim.pack 调用 git 时临时生效；锁文件和 origin 里始终是真实 GitHub 地址
local MIRROR = (USER.mirror and USER.mirror ~= "") and USER.mirror:gsub("/*$", "/") or nil

-- 用 GIT_CONFIG_* 环境变量临时给 git 加配置，执行完恢复原样，不污染全局 git 和 :terminal
local function with_git_env(fn)
  local cfg = {
    { "http.lowSpeedLimit", "1000" },            -- 低于 1KB/s 持续 20 秒自动放弃
    { "http.lowSpeedTime",  "20" },
  }
  if MIRROR then
    table.insert(cfg, { "url." .. MIRROR .. "https://github.com/.insteadOf", "https://github.com/" })
  end
  local base = tonumber(vim.env.GIT_CONFIG_COUNT) or 0   -- 保留用户自己已有的 GIT_CONFIG_*
  local env = { GIT_TERMINAL_PROMPT = "0", GIT_CONFIG_COUNT = tostring(base + #cfg) }
  for i, kv in ipairs(cfg) do
    env["GIT_CONFIG_KEY_" .. (base + i - 1)], env["GIT_CONFIG_VALUE_" .. (base + i - 1)] = kv[1], kv[2]
  end
  local saved = {}
  for k, v in pairs(env) do saved[k] = vim.env[k]; vim.env[k] = v end
  local ok, err = pcall(fn)
  for k in pairs(env) do vim.env[k] = saved[k] end
  return ok, err
end

-- 旧版手动安装的目录会和 vim.pack 重复加载
local old_dir = vim.fn.stdpath("data") .. "/site/pack/plugins"
if vim.fn.isdirectory(old_dir) == 1 then
  vim.notify("发现旧插件目录（会和 vim.pack 重复加载），请删除:\n" .. old_dir, L.WARN)
end

-- 下载中断会留下只有 .git 的空仓库：vim.pack 认为已安装，但 require 找不到。删掉让它重装
for _, spec in ipairs(PLUGINS) do
  local dir = PACK_DIR .. pname(spec)
  if vim.fn.isdirectory(dir) == 1 then
    local broken = true
    for name in vim.fs.dir(dir) do
      if name ~= ".git" then broken = false; break end
    end
    if broken then vim.fn.delete(dir, "rf") end
  end
end

local pack_ok, pack_err = with_git_env(function() vim.pack.add(PLUGINS, { confirm = false }) end)
if not pack_ok then
  vim.notify("vim.pack 出错: " .. tostring(pack_err), L.ERROR)
  for _, spec in ipairs(PLUGINS) do        -- 降级：直接加载本地已有的插件（不需要 git / 网络）
    if vim.fn.isdirectory(PACK_DIR .. pname(spec)) == 1 then try_cmd("packadd! " .. pname(spec)) end
  end
end

local function pack_run(msg, fn)
  vim.notify(msg .. (MIRROR and ("（经镜像 " .. MIRROR .. "）") or "") .. " ...")
  local ok, err = with_git_env(fn)
  if not ok then vim.notify("失败: " .. tostring(err), L.ERROR) end
  -- 会打开确认页：:write 应用，:quit 放弃；应用后 :restart 生效
end

cmd("PackUpdate", function(a)
  pack_run("正在检查插件更新", function() vim.pack.update(#a.fargs > 0 and a.fargs or nil) end)
end, { nargs = "*", desc = "Update plugins",
       complete = function() return vim.tbl_map(pname, PLUGINS) end })

-- 换机器 / 回滚：把插件恢复到 nvim-pack-lock.json 记录的版本
cmd("PackSync", function()
  pack_run("正在按锁文件同步插件", function() vim.pack.update(nil, { target = "lockfile" }) end)
end, { desc = "Sync plugins to lockfile" })

cmd("PackClean", function()
  local keep, names = {}, {}
  for _, s in ipairs(PLUGINS) do keep[pname(s)] = true end
  local ok, list = pcall(vim.pack.get)
  for _, p in ipairs(ok and list or {}) do
    if not keep[p.spec.name] and not p.active then table.insert(names, p.spec.name) end
  end
  if #names == 0 then return vim.notify("没有需要清理的插件") end
  if vim.fn.confirm("删除以下插件？\n  " .. table.concat(names, "\n  "), "&Yes\n&No", 2) ~= 1 then return end
  local del_ok, err = pcall(vim.pack.del, names)
  vim.notify(del_ok and ("已删除: " .. table.concat(names, ", ")) or tostring(err), del_ok and L.INFO or L.ERROR)
end, { desc = "Remove unused plugins" })

-- 插件加载保护：模块缺失 / setup 出错时跳过这一块（连同相关快捷键），不影响其余配置
local missing = {}
local PLUGIN_OF = { ["multicursor-nvim"] = "multicursor.nvim", overseer = "overseer.nvim" }
local function use(mod, setup)
  local ok, m = pcall(require, mod)
  if not ok then
    if tostring(m):find("module '" .. mod .. "' not found", 1, true) then
      local p = mod:match("^mini%.") and "mini.nvim" or PLUGIN_OF[mod] or mod
      if not vim.tbl_contains(missing, p) then table.insert(missing, p) end
    else
      vim.notify(("%s 加载出错:\n%s"):format(mod, m), L.ERROR)
    end
    return nil
  end
  if setup then
    local ok2, err = pcall(setup, m)
    if not ok2 then
      vim.notify(("%s 配置出错，已跳过:\n%s"):format(mod, err), L.ERROR)
      return nil
    end
  end
  return m
end

----------------------------------------------------------------------
-- 1. 选项 (hlsearch/incsearch/autoread/wildmenu/showcmd/termguicolors 已默认开启)
----------------------------------------------------------------------
o.number       = true
o.cursorline, o.cursorcolumn = true, true
o.cursorlineopt = "screenline,number"                  -- 只高亮当前屏幕行，并高亮行号
o.signcolumn   = "yes"
o.scrolloff    = 2
o.colorcolumn  = tostring(USER.width + 1)
o.list         = true
o.listchars    = "tab:│ ,trail:·,nbsp:."
o.winborder    = "rounded"
pcall(function() o.pumborder = "rounded" end)          -- 0.12：补全菜单边框
o.smoothscroll = true                                  -- 折行时按屏幕行平滑滚动
o.splitkeep    = "screen"                              -- 开/关分屏时文本不跳动
o.inccommand   = "split"                               -- :s 替换实时预览（含屏幕外匹配）
o.virtualedit  = "block"                               -- 可视块可越过行尾
o.updatetime   = 300

o.wrap, o.linebreak, o.breakindent = true, true, true
o.whichwrap    = "b,s,<,>,[,]"

o.expandtab = true
o.shiftwidth, o.tabstop, o.softtabstop = USER.indent, USER.indent, USER.indent
o.shiftround = true

o.ignorecase, o.smartcase = true, true

o.undofile      = true
o.confirm       = true
o.fileencodings = "ucs-bom,utf-8,gb18030,latin1"   -- Big5 文件请手动 :e ++enc=big5
o.fileformats   = "unix,dos"                        -- [Win] 新文件统一用 LF；已有 CRLF 文件照原样读写
o.spelllang     = "en_us,cjk"                       -- 拼写检查时不把中日韩文字标红

-- 默认按缩进折叠；有 treesitter 解析器或 LSP foldingRange 时自动换成更准的（见第 8、9 节）
o.foldmethod, o.foldlevel = "indent", 99
o.foldtext = ""                                     -- 折叠行保留原文的语法高亮

-- Ordinary multi-key mappings (gg, gr*, gq*, etc.) use Nvim's normal timeout.
-- mini.clue no longer intercepts these built-in prefixes.
o.timeout      = true
o.timeoutlen   = 1000
o.ttimeout     = true
o.ttimeoutlen  = 100
o.switchbuf    = "useopen,uselast"
o.splitright, o.splitbelow = true, true

-- 插入模式补全：无 LSP 用 0.12 原生自动补全；有 LSP 的缓冲区改由 LSP 自动补全接管（第 9 节）
-- 菜单操作全部用内置键：<C-n>/<C-p> 选择  <C-y> 确认  <C-e> 取消
o.completeopt  = "menu,menuone,noselect,popup,fuzzy"
o.autocomplete = USER.autocomplete

-- 命令行补全：0.12 的 wildtrigger() 实现边输入边弹出菜单（: / ? 都有效）
-- 下面的 <Up>/<Down> 映射来自 :h wildtrigger() 的官方示例：菜单打开时仍可翻历史
o.path        = o.path .. ",**"
o.wildignore  = "*/node_modules/*,*/.git/*,*/target/*,*/dist/*,*.o,*.pyc,"
             .. "*/__pycache__/*,*/.venv/*,*/.mypy_cache/*,*/.ruff_cache/*,*/.pytest_cache/*"
o.wildoptions = "pum,fuzzy"
if vim.fn.exists("*wildtrigger") == 1 and pcall(function() o.wildmode = "noselect:lastused,full" end) then
  au("CmdlineChanged", { group = group, pattern = { ":", "/", "?" },
                         callback = function() vim.fn.wildtrigger() end })
  map("c", "<Up>",   function() return vim.fn.wildmenumode() == 1 and "<C-e><Up>"   or "<Up>"   end, { expr = true })
  map("c", "<Down>", function() return vim.fn.wildmenumode() == 1 and "<C-e><Down>" or "<Down>" end, { expr = true })
else
  o.wildmode = "longest:full,full"
end

o.formatlistpat = [[^\s*\(\d\+\|[-*]\)\+[\]:.)}\t ]\s*]]
vim.opt.formatoptions:append("n")

-- 剪贴板延后设置：检测剪贴板工具可能较慢（SSH / WSL），不拖慢启动
-- （Windows 发行版自带 win32yank.exe，unnamedplus 直接可用）
vim.schedule(function() o.clipboard = USER.clipboard end)

----------------------------------------------------------------------
-- 2. 主题
----------------------------------------------------------------------
o.background = USER.background
if not try_cmd("colorscheme " .. USER.colorscheme) then
  vim.notify(("配色 %s 不存在，已使用默认配色"):format(USER.colorscheme), L.WARN)
end
map("n", "<F10>", function()
  o.background = o.background == "dark" and "light" or "dark"
  vim.notify("背景: " .. o.background)
end, { desc = "Toggle dark/light" })

----------------------------------------------------------------------
-- 3. mini.nvim（尽量使用各模块的默认键）
----------------------------------------------------------------------
-- 通知用浮窗显示；历史记录：:lua MiniNotify.show_history()
use("mini.notify", function(m)
  m.setup()
  vim.notify = m.make_notify()
end)

use("mini.starter",    function(m) m.setup() end)
use("mini.pairs",      function(m) m.setup() end)
use("mini.statusline", function(m) m.setup({ use_icons = false }) end)
use("mini.tabline",    function(m) m.setup({ show_icons = false }) end)
use("mini.move",       function(m) m.setup() end)   -- 默认键 <M-h/j/k/l>：普通模式移动行，可视模式移动选区

-- 当前代码块的缩进范围；只保留 [i / ]i 跳到范围边界，避免和 mini.ai 的 ai/ii 文本对象相撞
use("mini.indentscope", function(m)
  m.setup({
    symbol = "╎",
    draw = { delay = 100 },
    mappings = { object_scope = "", object_scope_with_border = "", goto_top = "[i", goto_bottom = "]i" },
  })
end)

-- 光标下单词的其他出现位置轻量高亮；大文件中关闭，避免额外扫描
use("mini.cursorword", function(m) m.setup() end)

-- 文本对象。额外: B=全文 I=缩进块 L=行 N=数字 D=诊断（来自 mini.extra，如 yaB 复制全文、dii 删缩进块）
-- 0.12 在可视/操作符模式内置了 an / in（按语法节点扩大/缩小选区）；
-- mini.ai 默认把 an/in 当作"下一个对象"会盖掉它，所以检测到内置映射就让出来（al/il 仍保留）
use("mini.ai", function(m)
  local custom = {}
  local ok, extra = pcall(require, "mini.extra")
  if ok then
    local g = extra.gen_ai_spec
    custom = { B = g.buffer(), D = g.diagnostic(), I = g.indent(), L = g.line(), N = g.number() }
  end
  local builtin_an = vim.fn.maparg("an", "x") ~= ""
  m.setup({
    n_lines = 500,
    custom_textobjects = custom,
    mappings = builtin_an and { around_next = "", inside_next = "" } or nil,
  })
end)

use("mini.bufremove", function(m)
  m.setup()
  map("n", "<leader>bd", function() m.delete() end, { desc = "Delete buffer (keep window)" })
end)

-- 会话：自动恢复“无文件参数启动”时的本地 Session.vim，并在退出/切换前保存。
-- 选择/保存/删除使用大写键，避开已有的查找与 picker 快捷键。
use("mini.sessions", function(m)
  local session_dir = vim.fs.joinpath(vim.fn.stdpath("state"), "sessions")
  vim.fn.mkdir(session_dir, "p")
  m.setup({ autoread = true, autowrite = true, directory = session_dir, file = "Session.vim" })
  map("n", "<leader>fS", function() m.select("read") end,   { desc = "Select session" })
  map("n", "<leader>fR", function() m.read() end,             { desc = "Read default session" })
  map("n", "<leader>fW", function() m.write("Session.vim", { force = true }) end, { desc = "Write session" })
  map("n", "<leader>fD", function() m.select("delete") end, { desc = "Delete session" })
end)

-- 访问记录：按项目保存 frecency（常用 + 最近使用）的文件历史，比 oldfiles 更有上下文。
use("mini.visits", function(m)
  m.setup()
  -- 没有 mini.pick 时仍可用 vim.ui.select；有 mini.pick 时下面 mini.extra 会接管这两个键。
  map("n", "<leader>fv", function() m.select_path() end,  { desc = "Visited files (project)" })
  map("n", "<leader>fV", function() m.select_path("") end, { desc = "Visited files (all)" })
end)

use("mini.git", function(m)
  m.setup()
  map({ "n", "x" }, "<leader>gs", function() m.show_at_cursor() end, { desc = "Git at cursor" })
end)

-- 默认键：[h ]h [H ]H 跳修改块；gh / gH 是"暂存 / 撤销"操作符，ghgh / gHgh 作用于光标处的块
use("mini.diff", function(m)
  m.setup({ view = { style = "sign" } })
  map("n", "<leader>go", function() m.toggle_overlay() end, { desc = "Diff overlay" })
end)

-- 文件管理器（类 oil：在缓冲区里编辑文件名即可 改名/新建/删除，按 = 应用，g? 帮助）
use("mini.files", function(m)
  m.setup()
  map("n", "<leader>e", function()
    local f = vim.api.nvim_buf_get_name(0)
    m.open((f ~= "" and vim.uv.fs_stat(f)) and f or nil, false)
  end, { desc = "File explorer (mini.files)" })
end)

-- 查找 + 接管 vim.ui.select（Overseer 的选择框也用它）
-- mini.pick 默认按 rg → fd → git → fallback 自选工具；这里只补一点：不在 git 仓库时别选 git
local function pick_tool(fast)
  if fast or vim.fs.root(0, ".git") then return nil end
  return "fallback"
end

local pick = use("mini.pick", function(m)
  m.setup()
  vim.ui.select = m.ui_select
  local b = m.builtin
  map("n", "<leader>ff", function() b.files({ tool = pick_tool(has("rg") or has("fd")) }) end, { desc = "Files" })
  map("n", "<leader>fg", function()
    local t = pick_tool(has("rg"))
    if t then b.grep({ tool = t }) else b.grep_live() end   -- 实时搜索需要 rg/git
  end, { desc = "Grep" })
  map("n", "<leader>fw", function()
    b.grep({ pattern = vim.fn.expand("<cword>"), tool = pick_tool(has("rg")) })
  end, { desc = "Grep word" })
  map("n", "<leader>fb", function() b.buffers() end, { desc = "Buffers" })
  map("n", "<leader>fh", function() b.help() end,    { desc = "Help" })
  map("n", "<leader>fr", function() b.resume() end,  { desc = "Resume" })
end)

use("mini.extra", function(m)
  m.setup()
  if not pick then return end
  map("n", "<leader>fo", function() m.pickers.oldfiles() end,   { desc = "Recent files" })
  map("n", "<leader>fd", function() m.pickers.diagnostic() end, { desc = "Diagnostics" })
  map("n", "<leader>fk", function() m.pickers.keymaps() end,    { desc = "Keymaps" })
  map("n", "<leader>fs", function() m.pickers.lsp({ scope = "document_symbol" }) end, { desc = "Symbols (LSP)" })
  map("n", "<leader>fl", function() m.pickers.buf_lines({ scope = "current" }) end,   { desc = "Buffer lines" })
  if pcall(require, "mini.visits") then
    map("n", "<leader>fv", function() m.pickers.visit_paths() end,       { desc = "Visited files (project)" })
    map("n", "<leader>fV", function() m.pickers.visit_paths({ cwd = "" }) end, { desc = "Visited files (all)" })
  end
end)

if not pick then   -- 降级：内置命令（'path' 已含 **）
  map("n", "<leader>ff", ":find ",                   { desc = "Files (builtin)" })
  map("n", "<leader>fg", ":vimgrep //gj **" .. ("<Left>"):rep(6), { desc = "Grep (builtin)" })
  map("n", "<leader>fb", ":ls<cr>:b ",               { desc = "Buffers (builtin)" })
  map("n", "<leader>fh", ":help ",                   { desc = "Help (builtin)" })
  map("n", "<leader>fo", "<cmd>browse oldfiles<cr>", { desc = "Recent files (builtin)" })
  map("n", "<leader>fd", vim.diagnostic.setloclist,  { desc = "Diagnostics (builtin)" })
end

-- 包围：tpope/vim-surround 的社区通用键 ys / ds / cs / 可视 S（mini.surround 官方文档给出的兼容写法）
-- 原生 Vim 里这几个组合本来就无效，不占任何内置键
use("mini.surround", function(m)
  m.setup({
    mappings = {
      add = "ys", delete = "ds", replace = "cs",
      find = "", find_left = "", highlight = "", update_n_lines = "",
      suffix_last = "", suffix_next = "",
    },
    custom_surroundings = {   -- 左括号也不加内侧空格（其余字符默认就是原样包围）
      ["("] = { output = { left = "(", right = ")" } },
      ["["] = { output = { left = "[", right = "]" } },
      ["{"] = { output = { left = "{", right = "}" } },
      ["<"] = { output = { left = "<", right = ">" } },
    },
    search_method = "cover_or_next",
  })
  pcall(vim.keymap.del, "x", "ys")    -- 可视模式下 ys 会让 y 等待超时，改用 S
  map("x", "S", [[:<C-u>lua MiniSurround.add('visual')<CR>]], { silent = true, desc = "Surround selection" })
  map("n", "yss", "ys_", { remap = true, desc = "Surround line" })
end)

-- 按键提示
local clue_mod = use("mini.clue", function(clue)
  local clues = {
    -- 只把工作流前缀交给 clue；g / z / [ / ] / <C-w> / 寄存器等仍由
    -- Neovim 原生按键解析，避免普通命令被 clue 的 buffer-local trigger 接管。
    { mode = { "n", "x" }, keys = "<Leader>b", desc = "+Buffer" },
    { mode = { "n", "x" }, keys = "<Leader>c", desc = "+Code" },
    { mode = { "n", "x" }, keys = "<Leader>e", desc = "+Explorer" },
    { mode = { "n", "x" }, keys = "<Leader>f", desc = "+Find / Files" },
    { mode = { "n", "x" }, keys = "<Leader>g", desc = "+Git / Go" },
    { mode = { "n", "x" }, keys = "<Leader>o", desc = "+Overseer" },
    { mode = { "n", "x" }, keys = "<Leader>p", desc = "+Python" },
    { mode = { "n", "x" }, keys = "<Leader>t", desc = "+LaTeX" },
    { mode = { "n", "x" }, keys = "<Leader>u", desc = "+Toggle / UI" },
  }

  clue.setup({
    triggers = {
      { mode = { "n", "x" }, keys = "<Leader>" },
    },
    clues = clues,
    -- 查询本身不依赖 'timeoutlen'；这里只控制浮窗何时出现。稍微延后，避免短暂停顿就弹窗打断输入。
    window = { delay = 600 },
  })
end)

----------------------------------------------------------------------
-- 4. 多光标：键位与 0.13 内置多光标完全一致
--    0.13+（USER.native_multicursor）：直接用内置多光标，这里什么都不做。
--    0.12：用 multicursor.nvim 模拟 0.13 的默认键：
--      Q 放置/删除   [count]Q 在后 count 个搜索匹配处加光标   gQ 找回
--      <C-LeftMouse> 鼠标放置/删除   <C-l> 清除（同时保留清高亮的默认行为）
--    额外：Q 放置时会暂停其他光标（插件特性），<Esc> 恢复；未暂停时 <Esc> 也会清除
--    放在 mini.clue 之后：部分 mini.clue 版本会自己映射 Q（用于重放宏），这里要覆盖它。
----------------------------------------------------------------------
if not NATIVE_MC then
  use("multicursor-nvim", function(mc)
    mc.setup()

    map("n", "Q", function()
      local n = vim.v.count
      if n == 0 then return mc.toggleCursor() end
      if vim.fn.getreg("/") == "" then return vim.notify("还没有搜索过，先用 /pattern 或 * 搜索", L.WARN) end
      for _ = 1, n do mc.searchAddCursor(1) end
    end, { desc = "Toggle cursor / [count] add at search" })
    map("x", "Q", function() mc.toggleCursor() end, { desc = "Toggle cursor" })
    map("n", "gQ", function() mc.restoreCursors() end, { desc = "Restore cleared cursors" })

    map("n", "<C-LeftMouse>",   mc.handleMouse,        { desc = "Toggle cursor (mouse)" })
    map("n", "<C-LeftDrag>",    mc.handleMouseDrag)
    map("n", "<C-LeftRelease>", mc.handleMouseRelease)

    -- 仅在存在多光标时生效
    mc.addKeymapLayer(function(set)
      set("n", "<Esc>", function()
        if not mc.cursorsEnabled() then mc.enableCursors() else mc.clearCursors() end
      end)
      set("n", "<C-l>", function()   -- 与 0.13 一致：<C-l> 清除多光标 + 清搜索高亮
        mc.clearCursors()
        vim.cmd("nohlsearch")
      end)
    end)

    local function mc_hl()
      local hl = vim.api.nvim_set_hl
      hl(0, "MultiCursorCursor",         { reverse = true })
      hl(0, "MultiCursorVisual",         { link = "Visual" })
      hl(0, "MultiCursorSign",           { link = "SignColumn" })
      hl(0, "MultiCursorMatchPreview",   { link = "Search" })
      hl(0, "MultiCursorDisabledCursor", { reverse = true })
      hl(0, "MultiCursorDisabledVisual", { link = "Visual" })
      hl(0, "MultiCursorDisabledSign",   { link = "SignColumn" })
    end
    mc_hl()
    au("ColorScheme", { group = group, callback = mc_hl })
  end)
end

----------------------------------------------------------------------
-- 5. Overseer (v2)
----------------------------------------------------------------------
-- 自定义组件：任务一启动就通知 (OverseerRun / OverseerShell / 重跑 / LaTeX / Python 都会触发)
-- 用 rawset 注册，避免 lua_ls 对 package.preload 的字段注入告警
rawset(package.preload, "overseer.component.on_start_notify", function()
  return {
    desc = "vim.notify when task starts",
    constructor = function()
      return {
        on_start = function(_, task)
          local c = type(task.cmd) == "table" and table.concat(task.cmd, " ") or tostring(task.cmd)
          if vim.fn.strcharlen(c) > 70 then c = vim.fn.strcharpart(c, 0, 67) .. "…" end
          vim.schedule(function()
            vim.notify(("▶ %s\n  %s\n  <Space>oo 查看输出"):format(task.name, c))
          end)
        end,
      }
    end,
  }
end)

local overseer = use("overseer", function(ov)
  ov.setup({
    task_list = { direction = "right", min_width = 35, max_width = 45 },
    component_aliases = {
      -- 注意：这是 Overseer v2 官方 default 列表的拷贝，再加上 on_start_notify。
      -- 升级 Overseer 后如果官方默认组件有变化，需要对照 :h overseer 手动同步
      default = {
        "on_start_notify",
        "on_exit_set_status",
        { "on_complete_notify", system = "unfocused" },   -- Neovim 不在前台时发桌面通知
        { "on_complete_dispose", require_view = { "SUCCESS", "FAILURE" } },
      },
    },
  })

  map("n", "<leader>or", "<cmd>OverseerRun<cr>",        { desc = "Run task" })
  map("n", "<leader>oo", "<cmd>OverseerToggle<cr>",     { desc = "Task list" })
  map("n", "<leader>oa", "<cmd>OverseerTaskAction<cr>", { desc = "Task action" })
  map("n", "<leader>os", ":OverseerShell ",             { desc = "Shell cmd as task" })
  map("n", "<leader>ol", function()
    local last
    for _, t in ipairs(ov.list_tasks()) do
      if not last or t.id > last.id then last = t end
    end
    if last then ov.run_action(last, "restart")   -- 重跑时也会触发启动通知
    else vim.notify("还没有运行过任务", L.WARN) end
  end, { desc = "Restart last task" })
end)

----------------------------------------------------------------------
-- 6. 通用快捷键（刻意保持很少；能用内置键的都不再自定义）
----------------------------------------------------------------------
-- 保存：无名缓冲区 / 只读等错误给出提示，而不是一串报错
local function save(vimcmd)
  if vim.bo.buftype ~= "" then
    return vim.notify("当前缓冲区不是普通文件，无法保存", L.WARN)
  end
  if vim.api.nvim_buf_get_name(0) == "" then
    return vim.notify("缓冲区还没有文件名，请用 :w 文件名 保存", L.WARN)
  end
  local ok, err = pcall(function() vim.cmd(vimcmd) end)
  if not ok then
    err = tostring(err)
    -- 直接提取 "E45: ..." 这样的部分，取不到就用原文
    local msg = err:match("E%d+:.*") or err
    vim.notify(msg, L.ERROR)
  end
end
map({ "n", "x", "i" }, "<C-s>", function() save("update") end, { desc = "Save" })
map("i", "<M-s>", vim.lsp.buf.signature_help, { desc = "Signature help" })

-- 终端模式回到普通模式（:h terminal-input 推荐的做法；单个 <Esc> 仍发给终端里的程序）
map("t", "<Esc><Esc>", [[<C-\><C-n>]], { desc = "Exit terminal mode" })

-- 折行时按屏幕行移动；带计数（如 5j）仍按真实行，不影响相对跳转
map({ "n", "x" }, "j", "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })
map({ "n", "x" }, "k", "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
map({ "n", "x" }, "<Down>", "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })
map({ "n", "x" }, "<Up>",   "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
map("i", "<Down>", [[pumvisible() ? "\<Down>" : "\<C-o>gj"]], { expr = true })  -- 补全菜单中仍用于选择
map("i", "<Up>",   [[pumvisible() ? "\<Up>"   : "\<C-o>gk"]], { expr = true })
map({ "n", "x" }, "<Home>", "^")
map({ "n", "x" }, "<End>",  "g_")
map("i", "<Home>", "<Esc>^i", { desc = "Insert mode: Jump to home of line non-blank" })
map("i", "<End>", "<Esc>g_a", { desc = "Insert mode: Jump to end of line non-blank" })
map("n", "<PageUp>", "{")
map("n", "<PageDown>", "}")

map("i", "<C-BS>", "<C-w>")
map("i", "<C-Del>", "<C-o>dw")

-- 可视模式 (x) 下的缩进保持选中
map("x", "<", "<gv")
map("x", ">", ">gv")

-- 插入时间 (<C-d> 保留给内置的"减少缩进")
map("i", "<M-d>", function() return os.date("%Y-%m-%d %H:%M:%S") end, { expr = true, desc = "Insert datetime" })

-- Tab：片段占位符跳转 > 菜单下一项 > 行首/空白后缩进 > LSP 补全 或 关键字补全
map("i", "<Tab>", function()
  if vim.snippet.active({ direction = 1 }) then return "<Cmd>lua vim.snippet.jump(1)<CR>" end
  if vim.fn.pumvisible() == 1 then return "<C-n>" end
  local col = vim.fn.col(".") - 1
  if col == 0 or vim.fn.getline("."):sub(col, col):match("%s") then return "<Tab>" end
  if #vim.lsp.get_clients({ bufnr = 0, method = "textDocument/completion" }) > 0 then
    return "<Cmd>lua vim.lsp.completion.get()<CR>"
  end
  return "<C-n>"
end, { expr = true })
map("i", "<S-Tab>", function()
  if vim.snippet.active({ direction = -1 }) then return "<Cmd>lua vim.snippet.jump(-1)<CR>" end
  return vim.fn.pumvisible() == 1 and "<C-p>" or "<S-Tab>"
end, { expr = true })

-- `-` 打开上级目录：0.13 由内置 dir 插件提供；0.12 用 netrw 模拟同一个键（vim-vinegar 习惯）
if vim.fn.maparg("-", "n") == "" then
  map("n", "-", function()
    if vim.fn.exists(":Explore") == 2 then vim.cmd("Explore") else vim.cmd.edit(vim.fn.expand("%:p:h")) end
  end, { desc = "Open parent directory" })
end

-- 0.12 自带的可选插件：撤销树 / 目录对比 (:DiffTool dir1 dir2)
if try_cmd("packadd nvim.undotree") and vim.fn.exists(":Undotree") == 2 then
  map("n", "<leader>uu", "<cmd>Undotree<cr>", { desc = "Undo tree" })
end
try_cmd("packadd nvim.difftool")

-- <Leader>u：开关类（LazyVim 风格分组）
map("n", "<leader>uh", function()
  local on = not vim.lsp.inlay_hint.is_enabled({ bufnr = 0 })
  vim.lsp.inlay_hint.enable(on, { bufnr = 0 })
  vim.notify("内联提示: " .. (on and "开" or "关"))
end, { desc = "Toggle inlay hints" })

-- 诊断：行尾文字 <-> 当前行下方展开（长消息不再被截断）
map("n", "<leader>ud", function()
  local on = not vim.diagnostic.config().virtual_lines
  vim.diagnostic.config({ virtual_lines = on and { current_line = true } or false, virtual_text = not on })
  vim.notify("诊断显示: " .. (on and "当前行展开" or "行尾"))
end, { desc = "Toggle diagnostic lines" })

map("n", "<leader>us", function()
  vim.wo.spell = not vim.wo.spell
  vim.notify("拼写检查: " .. (vim.wo.spell and "开" or "关"))
end, { desc = "Toggle spell" })

----------------------------------------------------------------------
-- 7. 注释装饰（命令：:CommentRule 分隔线 / :FileHeader 文件头）
----------------------------------------------------------------------
local DECO = { width = USER.width, rule = "-", head = "=" }
local dw = vim.fn.strdisplaywidth

-- 作者：USER.author > git config user.name > 系统用户名
local function get_author()
  if USER.author and USER.author ~= "" then return USER.author end
  local ok, r = pcall(function()
    return vim.system({ "git", "config", "user.name" }, { text = true }):wait(2000)
  end)
  local name = (ok and r.code == 0) and vim.trim(r.stdout or "") or ""
  if name ~= "" then return name end
  return vim.env.USER or vim.env.USERNAME or "unknown"
end

local function comment_parts()
  local cs = vim.bo.commentstring
  if cs == nil or cs == "" then cs = "# %s" end
  local prefix, suffix = cs:match("^(.-)%%s(.-)$")
  return vim.trim(prefix or "#"), vim.trim(suffix or "")
end

local function rule_line(char)
  local p, s = comment_parts()
  local p_str = p ~= "" and (p .. " ") or ""
  local s_str = s ~= "" and (" " .. s) or ""
  return p_str .. string.rep(char, math.max(3, DECO.width - dw(p_str .. s_str))) .. s_str
end

local function text_line(text)
  local p, s = comment_parts()
  local left = (p ~= "" and (p .. " ") or "") .. text
  if s == "" then return left end
  return left .. string.rep(" ", math.max(1, DECO.width - dw(left) - dw(s))) .. s
end

local function editable()
  if vim.bo.modifiable then return true end
  vim.notify("当前缓冲区不可修改", L.WARN)
  return false
end

-- 当前行为空：替换该行；否则插入到当前行下方
cmd("CommentRule", function()
  if not editable() then return end
  local row = vim.api.nvim_win_get_cursor(0)[1]
  local blank = vim.trim(vim.api.nvim_get_current_line()) == ""
  local start = blank and row - 1 or row
  vim.api.nvim_buf_set_lines(0, start, blank and row or start, false, { rule_line(DECO.rule) })
  vim.api.nvim_win_set_cursor(0, { start + 1, 0 })
end, { desc = "Insert comment separator line" })

cmd("FileHeader", function()
  if not editable() then return end
  local prefix = comment_parts()
  local top = vim.api.nvim_buf_get_lines(0, 0, 3, false)
  for _, line in ipairs(top) do     -- 文件头可能在 shebang 之后，检查前几行
    if line:match("^%s*" .. vim.pesc(prefix) .. "%s*" .. DECO.head:rep(3)) then
      return vim.notify("文件头已存在", L.WARN)
    end
  end
  local first = top[1] or ""
  local name = vim.fn.expand("%:t")
  local bar = rule_line(DECO.head)
  local header = {
    bar,
    text_line("File    : " .. (name ~= "" and name or "[No Name]")),
    text_line("Created : " .. os.date("%Y-%m-%d %H:%M:%S")),
    text_line("Author  : " .. get_author()),
    bar,
    "",
  }
  local start = (first:match("^#!") or first:match("^%s*<[!?]")) and 1 or 0  -- 跳过 shebang / <?xml
  vim.api.nvim_buf_set_lines(0, start, start, false, header)
  vim.api.nvim_win_set_cursor(0, { start + #header, 0 })
end, { desc = "Insert file header" })

map({ "n", "i" }, "<F11>", "<Cmd>CommentRule<CR>", { desc = "Insert comment separator line" })
map({ "n", "i" }, "<F12>", "<Cmd>FileHeader<CR>",  { desc = "Insert file header" })

----------------------------------------------------------------------
-- 8. 自动命令
----------------------------------------------------------------------
local function highlight_yank()
  if vim.fn.has("nvim-0.13") == 1 and vim.hl.hl_op then
    vim.hl.hl_op({ timeout = 200 })
  elseif vim.hl.on_yank then
    vim.hl.on_yank({ timeout = 200 })
  end
end
au("TextYankPost", { group = group, callback = highlight_yank })

-- 回到 Neovim / 离开终端时检查文件是否被外部修改
-- （0.13 的 'autoread' 改为文件系统监视，这条在 0.13 上只是多一层保险）
au({ "FocusGained", "TermClose", "TermLeave" }, {
  group = group,
  callback = function() if vim.o.buftype ~= "nofile" then try_cmd("checktime") end end,
})

-- 终端窗口去掉行号等干扰
au("TermOpen", {
  group = group,
  callback = function()
    local wo = vim.wo[0][0]
    wo.number, wo.signcolumn, wo.cursorline, wo.cursorcolumn = false, "no", false, false
  end,
})

-- 调整 Neovim 窗口大小后均分各分屏
au("VimResized", { group = group, callback = function() try_cmd("wincmd =") end })

-- help / quickfix 按 q 关闭（man、checkhealth 内置已有 q，不再重复）
au("FileType", {
  group = group, pattern = { "help", "qf" },
  callback = function(args)
    vim.bo[args.buf].buflisted = false
    map("n", "q", function() if not try_cmd("close") then try_cmd("bdelete") end end,
        { buffer = args.buf, nowait = true, desc = "Close" })
  end,
})

-- 恢复上次光标位置（git 提交信息等临时文件除外）
au("BufReadPost", {
  group = group,
  callback = function(args)
    local name = vim.api.nvim_buf_get_name(args.buf)
    if name:match("COMMIT_EDITMSG$") or name:match("git%-rebase%-todo$") then return end
    if vim.api.nvim_win_get_buf(0) ~= args.buf then return end
    local mark = vim.api.nvim_buf_get_mark(args.buf, '"')
    if mark[1] > 0 and mark[1] <= vim.api.nvim_buf_line_count(args.buf) then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
      vim.cmd("normal! zz")
    end
  end,
})

-- 项目根目录：自动切换 (找不到就用文件所在目录)；Overseer / Pick 都依赖 cwd
-- :CdHere 手动切到文件目录并暂停自动切换；:CdRoot 回到项目根并恢复
-- [Win] 路径比较前一律 vim.fs.normalize（统一 / 分隔符与盘符大小写），否则 C:\a 与 C:/a 会被当成不同目录
vim.g.auto_cd = USER.auto_cd
local home = vim.fs.normalize(vim.uv.os_homedir() or "")

local function project_root(buf)
  local name = vim.api.nvim_buf_get_name(buf)
  if vim.bo[buf].buftype ~= "" or name == "" or name:find("://", 1, true) then return end  -- 虚拟缓冲区
  if vim.bo[buf].filetype == "directory" or vim.fn.isdirectory(name) == 1 then return end   -- dir / netrw
  local root = vim.fs.root(buf, USER.root_markers)
  root = root and vim.fs.normalize(root)
  if not root or root == home then root = vim.fs.dirname(name) end  -- 家目录是 dotfiles 仓库时不切到 ~
  return vim.fs.normalize(root)
end

local function cd(dir)
  if not dir then return end
  dir = vim.fs.normalize(dir)
  if dir ~= vim.fs.normalize(vim.fn.getcwd()) and vim.fn.isdirectory(dir) == 1 then
    pcall(vim.fn.chdir, dir)
  end
end

au("BufEnter", {
  group = group,
  callback = function(args)
    if vim.g.auto_cd then cd(project_root(args.buf)) end
    -- 保证单一的 Leader clue trigger 最后创建，避免被后续 buffer-local mapping 遮住。
    if clue_mod then vim.schedule(function()
      if vim.api.nvim_buf_is_valid(args.buf) then
        pcall(clue_mod.ensure_buf_triggers, args.buf)
      end
    end) end
  end,
})

cmd("CdHere", function()
  vim.g.auto_cd = false
  cd(vim.fn.expand("%:p:h"))
  vim.notify("cwd: " .. vim.fn.getcwd() .. "\n已暂停自动切换（:CdRoot 恢复）")
end, { desc = "cd to file dir (pause auto cd)" })
cmd("CdRoot", function()
  vim.g.auto_cd = true
  cd(project_root(0))
  vim.notify("cwd: " .. vim.fn.getcwd() .. "\n已恢复自动切换项目根目录")
end, { desc = "cd to project root (resume auto cd)" })

-- 保存时去掉行尾空白
-- 以下情况跳过：markdown / diff、二进制、大文件、EditorConfig 写了 trim_trailing_whitespace = false、
-- 用 <Space>uw 关掉了当前缓冲区、或 USER.trim_on_save = false
vim.g.trim_on_save = USER.trim_on_save
local NO_TRIM = { markdown = true, diff = true }
local function trim_enabled(buf)
  local v = vim.b[buf].trim_on_save
  if v == nil then return vim.g.trim_on_save end
  return v
end

au("BufWritePre", {
  group = group,
  callback = function(args)
    local buf, bo = args.buf, vim.bo[args.buf]
    if not trim_enabled(buf) or bo.binary or not bo.modifiable
      or NO_TRIM[bo.filetype] or vim.b[buf].bigfile then return end
    local ec = vim.b[buf].editorconfig
    if type(ec) == "table" and ec.trim_trailing_whitespace == "false" then return end
    vim.api.nvim_buf_call(buf, function()
      local view = vim.fn.winsaveview()
      vim.cmd([[keeppatterns silent! %s/\s\+$//e]])
      vim.fn.winrestview(view)
    end)
  end,
})

map("n", "<leader>uw", function()
  vim.b.trim_on_save = not trim_enabled(0)
  vim.notify("保存时去行尾空白（当前缓冲区）: " .. (vim.b.trim_on_save and "开" or "关"))
end, { desc = "Toggle trim on save" })

-- 大文件降级
au("BufReadPre", {
  group = group,
  callback = function(args)
    local st = vim.uv.fs_stat(vim.api.nvim_buf_get_name(args.buf))
    if st and st.size > USER.bigfile_mb * 1024 * 1024 then
      vim.b[args.buf].bigfile = true
      vim.b[args.buf].minidiff_disable = true
      vim.b[args.buf].miniindentscope_disable = true
      vim.b[args.buf].minicursorword_disable = true
      vim.bo[args.buf].undofile = false
      vim.bo[args.buf].swapfile = false
      vim.notify(("大文件 (>%dMB)：已关闭高亮 / 折叠 / LSP / diff / undo 文件"):format(USER.bigfile_mb))
    end
  end,
})

-- 折叠方式记在缓冲区上（b:fold_expr），同一缓冲区在任何窗口打开都用同一种
-- 优先级：treesitter > LSP foldingRange > 'foldmethod' 默认的 indent
local function set_fold(buf, expr, force)
  if not force and vim.b[buf].fold_expr then return end
  vim.b[buf].fold_expr = expr
  for _, win in ipairs(vim.fn.win_findbuf(buf)) do
    local wo = vim.wo[win][0]
    wo.foldmethod, wo.foldexpr = "expr", expr
  end
end
au("BufWinEnter", {
  group = group,
  callback = function(args)
    local e = vim.b[args.buf].fold_expr
    if e then local wo = vim.wo[0][0]; wo.foldmethod, wo.foldexpr = "expr", e end
  end,
})

-- 有 treesitter 解析器就用它高亮 + 折叠，没有就用传统 syntax + 缩进折叠
-- 大文件：两种高亮都关（含 ftplugin 自启的 treesitter），折叠改手动，关十字光标线
au("FileType", {
  group = group,
  callback = function(args)
    local buf = args.buf
    if vim.b[buf].bigfile then
      vim.schedule(function()
        if not vim.api.nvim_buf_is_valid(buf) then return end
        pcall(vim.treesitter.stop, buf)
        vim.bo[buf].syntax = "OFF"
        for _, win in ipairs(vim.fn.win_findbuf(buf)) do
          local wo = vim.wo[win][0]
          wo.foldmethod, wo.cursorcolumn = "manual", false
        end
      end)
      return
    end
    local lang = vim.treesitter.language.get_lang(args.match)
    local ok, added = pcall(vim.treesitter.language.add, lang or "")
    if lang and ok and added and pcall(vim.treesitter.start, buf, lang) then
      set_fold(buf, "v:lua.vim.treesitter.foldexpr()", true)
    end
  end,
})

----------------------------------------------------------------------
-- 9. LSP (vim.lsp.config / enable)
--    内置默认键：K grn gra grr gri grt grx gO <C-]> 插入<C-s> [d ]d [D ]D <C-w>d gq
--    这里只补两个：grd（定义，和 gr* 一族对齐）、<Space>cf（整文件格式化）
----------------------------------------------------------------------
vim.diagnostic.config({
  virtual_text  = true,
  severity_sort = true,
  float         = { source = "if_many" },
  jump = {   -- [d / ]d（内置键）跳转后自动弹出该处诊断
    on_jump = function(d, buf)
      if d then vim.diagnostic.open_float({ bufnr = buf, scope = "cursor", focus = false }) end
    end,
  },
})

-- conda 安装位置：优先 $CONDA_EXE（conda init 设置，切换环境后仍指向 base），
-- 没有（如从桌面启动）时查常见安装路径
local CONDA_BASE = (function()
  local exe = vim.env.CONDA_EXE
  if exe and exe ~= "" then return vim.fs.dirname(vim.fs.dirname(vim.fs.normalize(exe))) end
  local localapp = vim.env.LOCALAPPDATA or ""
  local progdata = vim.env.ProgramData or "C:/ProgramData"
  local cands = IS_WIN and {   -- [Win] 用户级安装在 ~ 或 %LOCALAPPDATA%，"所有用户"安装在 %ProgramData%
    "~/miniconda3", "~/miniforge3", "~/anaconda3",
    localapp .. "/miniconda3", localapp .. "/miniforge3", localapp .. "/anaconda3",
    progdata .. "/miniconda3", progdata .. "/miniforge3", progdata .. "/anaconda3",
  } or { "~/miniconda3", "~/miniforge3", "~/anaconda3", "/opt/miniconda3", "/opt/miniforge3", "/opt/anaconda3" }
  for _, d in ipairs(cands) do
    d = vim.fs.normalize(d)
    if vim.uv.fs_stat(vim.fs.joinpath(d, "condabin")) then return d end
  end
end)()

-- 外部工具查找：先 PATH，再 USER.extra_path，再各平台常见目录，最后 conda base
local TOOL_DIRS = {}
local function add_dir(d) if d and d ~= "" then table.insert(TOOL_DIRS, vim.fs.normalize(d)) end end
for _, d in ipairs(USER.extra_path or {}) do add_dir(d) end
add_dir(vim.fn.stdpath("data") .. "/mason/bin")                   -- 若装过 mason
add_dir("~/go/bin")                                                -- go install 安装的 gopls / gofumpt 等工具
if IS_WIN then   -- [Win] 从开始菜单 / Neovide 启动时 PATH 常常不完整，补上常见安装位置
  local appdata, localapp = vim.env.APPDATA, vim.env.LOCALAPPDATA
  if appdata then
    add_dir(appdata .. "/npm")                                     -- npm i -g（.cmd 包装）
    for _, d in ipairs(vim.fn.glob(appdata .. "/Python/Python3*/Scripts", false, true)) do
      add_dir(d)                                                   -- pip install --user
    end
  end
  add_dir("~/scoop/shims")                                         -- scoop
  if localapp then add_dir(localapp .. "/Microsoft/WinGet/Links") end   -- winget
  add_dir("~/.cargo/bin")
end
if CONDA_BASE then
  if IS_WIN then
    add_dir(vim.fs.joinpath(CONDA_BASE, "Scripts"))
    add_dir(vim.fs.joinpath(CONDA_BASE, "Library/bin"))             -- conda-forge 的二进制包放在这里
  else
    add_dir(vim.fs.joinpath(CONDA_BASE, "bin"))
  end
end

-- 返回完整路径（Windows 会按 PATHEXT 自动补 .exe / .cmd / .bat），找不到返回 nil
-- [Win] 用完整路径启动，避免 executable() 认得 .cmd 但 jobstart / LSP 启动时找不到
local function find_exe(exe)
  local p = vim.fn.exepath(exe)
  if p ~= "" then return p end
  for _, d in ipairs(TOOL_DIRS) do
    p = vim.fn.exepath(vim.fs.joinpath(d, exe))
    if p ~= "" then return p end
  end
end

-- Python 解释器探测（basedpyright / 运行 / 测试 / REPL 共用）
-- 优先级：<Space>pv 手选 > USER.python > $VIRTUAL_ENV > 项目内 .venv/venv/env
--         > $CONDA_PREFIX（当前激活的 conda 环境）> conda base > PATH（Windows 另试 py 启动器）
local PY_ROOT = { { "pyproject.toml", "setup.py", "setup.cfg", "requirements.txt",
                    "pyrightconfig.json", "uv.lock" }, ".git" }
local py_chosen = {}   -- [项目根] = 解释器路径

local function venv_python(dir)
  if not dir or dir == "" then return end
  for _, rel in ipairs(IS_WIN and { "Scripts/python.exe", "python.exe" } or { "bin/python" }) do
    local p = vim.fs.joinpath(dir, rel)
    if vim.uv.fs_stat(p) then return p end
  end
end

-- [Win] WindowsApps\python.exe 是应用商店占位程序（只会打开 Microsoft Store），不是真解释器
local function real_python(p)
  if p and p ~= "" and not (IS_WIN and p:find("WindowsApps", 1, true)) then return p end
end

-- PATH 中的解释器（结果缓存；false = 找过但没有）
local path_py_cache
local function path_python()
  if path_py_cache ~= nil then return path_py_cache or nil end
  for _, exe in ipairs(IS_WIN and { "python", "python3" } or { "python3", "python" }) do
    local p = real_python(vim.fn.exepath(exe))
    if p then path_py_cache = p; return p end
  end
  if IS_WIN and has("py") then   -- [Win] python.org 安装器常只提供 py 启动器：问它真实路径
    local ok, r = pcall(function()
      return vim.system({ "py", "-3", "-c", "import sys; print(sys.executable)" }, { text = true }):wait(3000)
    end)
    local p = ok and r.code == 0 and real_python(vim.trim(r.stdout or "")) or nil
    if p then path_py_cache = p; return p end
  end
  path_py_cache = false
end

local function py_root(buf)
  local name = vim.api.nvim_buf_get_name(buf or 0)
  local r = vim.fs.root(buf or 0, PY_ROOT) or (name ~= "" and vim.fs.dirname(name)) or vim.fn.getcwd()
  return vim.fs.normalize(r)
end

local function python_for(root)
  if root and py_chosen[root] then return py_chosen[root] end
  if USER.python and USER.python ~= "" then return USER.python end
  local p = venv_python(vim.env.VIRTUAL_ENV)
  if p then return p end
  for _, d in ipairs({ ".venv", "venv", "env" }) do   -- .venv 也可以是指向 conda 环境的软链接
    p = root and venv_python(vim.fs.joinpath(root, d))
    if p then return p end
  end
  p = venv_python(vim.env.CONDA_PREFIX)          -- conda base 常驻激活，所以放在项目 venv 之后
  if p then return p end
  p = venv_python(CONDA_BASE)                    -- 从桌面启动时没有激活环境，用 conda base
  if p then return p end
  return path_python()
end

-- 告诉 basedpyright 用哪个解释器（否则第三方包会报"无法解析导入"）
-- 生成新 settings 表而不是原地修改：多个项目各自一个客户端，互不覆盖
local function pyright_set_python(client, p)
  if not p then return end
  client.settings = vim.tbl_deep_extend("force", client.settings or {}, { python = { pythonPath = p } })
  client:notify("workspace/didChangeConfiguration", { settings = client.settings })
end

local RUFF = find_exe("ruff")

local servers = {
  basedpyright = {
    cmd = { "basedpyright-langserver", "--stdio" }, filetypes = { "python" },
    root_markers = PY_ROOT,
    settings = {
      basedpyright = {
        disableOrganizeImports = RUFF ~= nil,     -- 有 ruff 时整理 import 交给它，避免两个同名操作
        analysis = { typeCheckingMode = USER.py_typecheck },
      },
    },
    on_init = function(client)
      pyright_set_python(client, python_for(client.root_dir and vim.fs.normalize(client.root_dir)))
    end,
  },
  ruff = {   -- lint + 格式化 + 整理 import；行宽等规则读 pyproject.toml / ruff.toml
    cmd = { "ruff", "server" }, filetypes = { "python" },
    root_markers = { { "pyproject.toml", "ruff.toml", ".ruff.toml" }, ".git" },
  },
  lua_ls = {
    cmd = { "lua-language-server" }, filetypes = { "lua" },
    root_markers = { ".luarc.json", ".luarc.jsonc", ".git" },
    settings = { Lua = {
      runtime = { version = "LuaJIT" },
      workspace = { library = { vim.env.VIMRUNTIME }, checkThirdParty = false },
    } },
  },
  bashls = {
    cmd = { "bash-language-server", "start" }, filetypes = { "sh", "bash" },
    root_markers = { ".git" },
  },
  dartls = {
    cmd = { "dart", "language-server", "--protocol=lsp" }, filetypes = { "dart" },
    root_markers = { "pubspec.yaml", ".git" },
  },
  gopls = {
    cmd = { "gopls" },
    filetypes = { "go", "gomod", "gowork", "gotmpl" },
    root_markers = { "go.work", "go.mod", ".git" },
    settings = {
      gopls = {
        gofumpt = true,
        staticcheck = true,
        analyses = {
          unusedparams = true,
          unusedwrite = true,
          nilness = true,
        },
        usePlaceholders = true,
        completeUnimported = true,
      },
    },
  },
}
for name, cfg in pairs(servers) do
  local exe = find_exe(cfg.cmd[1])
  if exe then                   -- 没装的服务器直接跳过
    cfg.cmd[1] = exe            -- 完整路径（Windows 下可能是 .exe / .cmd / .bat）
    vim.lsp.config(name, cfg)
    vim.lsp.enable(name)
  end
end

-- LSP 自动补全只使用服务器声明的 triggerCharacters。
-- 不再把 a-z/A-Z/_ 全部加入触发字符：那会让每个字母都触发 LSP 请求，
-- 官方文档明确提醒这种做法可能较慢。未自动弹出时，<Tab> 仍可手动请求 LSP 补全。

au("LspAttach", {
  group = group,
  callback = function(args)
    local b = args.buf
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    if not client then return end

    if vim.b[b].bigfile then    -- 大文件不挂 LSP
      vim.schedule(function() pcall(vim.lsp.buf_detach_client, b, client.id) end)
      return
    end

    local function supports(m) return client:supports_method(m, b) end
    local function opts(desc) return { buffer = b, desc = desc } end

    -- 补全：开了自动补全时，该缓冲区关掉原生 'autocomplete'，改由 LSP 自动弹出（避免两套菜单）
    -- 'autocomplete' 无法按缓冲区关闭时，保留原生的，LSP 补全改用内置 <C-x><C-o> 手动触发
    if supports("textDocument/completion") then
      local auto = vim.go.autocomplete
      if auto and not pcall(function() vim.bo[b].autocomplete = false end) then auto = false end
      vim.lsp.completion.enable(true, client.id, b, { autotrigger = auto })
    end

    -- 定义：内置已有 <C-]>（tagfunc）；grd 与 grn/gra/grr/gri/grt 一族对齐（kickstart.nvim 同款）
    if vim.fn.maparg("grd", "n") == "" then
      map("n", "grd", vim.lsp.buf.definition, opts("Definition"))
    end
    if supports("textDocument/formatting") then
      -- 整文件格式化；只格式化一段用内置 gq{motion}（LSP 已设置 'formatexpr'）
      map({ "n", "x" }, "<leader>cf", function() vim.lsp.buf.format({ bufnr = b }) end, opts("Format"))
    end

    -- 折叠：没有 treesitter 折叠时，用 LSP 的 foldingRange
    if supports("textDocument/foldingRange") then set_fold(b, "v:lua.vim.lsp.foldexpr()", false) end

    -- 0.12 可选能力：内联提示 / 联动编辑（改 HTML 开标签时同步闭标签）/ CodeLens（内置 grx 运行）
    if USER.inlay_hints and supports("textDocument/inlayHint") then
      vim.lsp.inlay_hint.enable(true, { bufnr = b })
    end
    if supports("textDocument/linkedEditingRange") and vim.lsp.linked_editing_range then
      pcall(vim.lsp.linked_editing_range.enable, true, { client_id = client.id })
    end
    if supports("textDocument/codeLens") and vim.lsp.codelens.enable then
      pcall(vim.lsp.codelens.enable, true, { bufnr = b })
    end

    -- LSP/ftplugin 会在此处新增 buffer-local mappings；Leader trigger 必须最后创建。
    if clue_mod then pcall(clue_mod.ensure_buf_triggers, b) end
  end,
})

----------------------------------------------------------------------
-- 10. 任务运行 + LaTeX
--     优先交给 Overseer：启动/完成都有通知、错误进 quickfix；没有 Overseer 时在底部终端运行
----------------------------------------------------------------------
-- 只在某种文件类型的缓冲区里生效的键（<LocalLeader> = 空格）
local function ft_keys(pattern, setup)
  au("FileType", {
    group = group, pattern = pattern,
    callback = function(a)
      setup(function(mode, lhs, rhs, desc) map(mode, lhs, rhs, { buffer = a.buf, desc = desc }) end, a.buf)
      if clue_mod then pcall(clue_mod.ensure_buf_triggers, a.buf) end
    end,
  })
end

-- t = { name, cmd, cwd, efm(可选，默认用 'errorformat'), watch(可选，保存时重跑的目录) }
local function run_job(t)
  if overseer then
    local comps = { { "on_output_quickfix", open_on_exit = "failure", items_only = true,
                      errorformat = t.efm }, "default" }
    if t.watch then table.insert(comps, { "restart_on_save", paths = { t.watch } }) end
    overseer.new_task({ name = t.name, cmd = t.cmd, cwd = t.cwd, components = comps }):start()
  else
    if t.watch then vim.notify("保存即重跑需要 overseer.nvim，本次只运行一次", L.WARN) end
    vim.cmd("botright 12new")
    vim.fn.jobstart(t.cmd, { term = true, cwd = t.cwd })
  end
end

local function latexmk(args, title)
  local file = vim.api.nvim_buf_get_name(0)
  if vim.fn.fnamemodify(file, ":e") ~= "tex" then
    return vim.notify("当前不是 .tex 文件", L.WARN)
  end
  local exe = find_exe("latexmk")   -- [Win] 用完整路径（MiKTeX / TeX Live 的 latexmk.exe）
  if not exe then
    return vim.notify("未找到 latexmk，请先安装 TeX Live / MiKTeX", L.ERROR)
  end
  local ok, err = try_cmd("silent update")
  if not ok then return vim.notify("保存失败: " .. tostring(err), L.ERROR) end
  if vim.fn.filereadable(file) == 0 then
    return vim.notify("当前文件还没保存到磁盘", L.ERROR)
  end
  local c = vim.list_extend(vim.list_extend({ exe }, args), { vim.fs.basename(file) })
  run_job({ name = title, cmd = c, cwd = vim.fs.dirname(file) })
end

local function view_pdf()
  local pdf = vim.fn.expand("%:p:r") .. ".pdf"
  if vim.fn.filereadable(pdf) == 0 then
    return vim.notify("找不到 PDF，请先编译 (<Space>tt)", L.WARN)
  end
  local viewers = vim.deepcopy(USER.pdf_viewers)
  if IS_WIN then   -- [Win] SumatraPDF 不锁文件（Adobe 会锁，latexmk 写不进去）、支持 synctex
    vim.list_extend(viewers, { "SumatraPDF",
      (vim.env.LOCALAPPDATA or "") .. "/SumatraPDF/SumatraPDF.exe",
      "C:/Program Files/SumatraPDF/SumatraPDF.exe" })
  end
  for _, v in ipairs(viewers) do
    local exe = find_exe(v)
    if exe and pcall(vim.system, { exe, pdf }, { detach = true }) then
      return vim.notify("用 " .. vim.fs.basename(exe) .. " 打开 " .. vim.fs.basename(pdf))
    end
  end
  local _, err = vim.ui.open(pdf)              -- 系统默认程序，macOS / Windows 也能用
  if err then vim.notify(err, L.ERROR) else vim.notify("用系统默认程序打开 PDF") end
end

-- -synctex=1：PDF ↔ 源码跳转；-file-line-error：错误格式为 file:line:，可被 quickfix 解析
local TEX = { USER.latex_engine, "-synctex=1", "-file-line-error", "-interaction=nonstopmode", "-halt-on-error" }
ft_keys({ "tex", "plaintex" }, function(k)
  k("n", "<LocalLeader>tt", function() latexmk(TEX, "LaTeX 编译") end, "Compile")
  k("n", "<LocalLeader>tw", function()
    latexmk(vim.list_extend({ "-pvc", "-view=none" }, TEX), "LaTeX 持续编译")   -- <Space>oa 停止
  end, "Continuous compile (-pvc)")
  k("n", "<LocalLeader>te", function() latexmk(vim.list_extend({ "-gg" }, TEX), "LaTeX 完全重建") end, "Full rebuild")
  k("n", "<LocalLeader>tc", function() latexmk({ "-c" }, "LaTeX 清理") end, "Clean aux (keep PDF)")
  k("n", "<LocalLeader>tv", view_pdf, "View PDF")
end)

----------------------------------------------------------------------
-- 11. Python（与 LaTeX 同样：优先交给 Overseer，错误进 quickfix；没有 Overseer 时在底部终端运行）
--     可选外部工具：ruff（lint/格式化）、项目环境里的 pytest / ipython；缺了只跳过对应功能
----------------------------------------------------------------------
-- 续行缩进用 1 个 shiftwidth（PEP 8 风格，内置默认是 2 个）
vim.g.python_indent = { open_paren = "shiftwidth()", continue = "shiftwidth()", closed_paren_align_last_line = false }

-- traceback：每个 File 行一条，最后的异常行作为消息；pytest --tb=line 输出 file:line: msg
-- （Windows 下 %f 会自动匹配 C: 盘符）
local PY_EFM     = [[%A  File "%f"\, line %l%.%#,%C %.%#,%Z%[%^ ]%\@=%m]]
local PYTEST_EFM = [[%f:%l: %m]]

local function term_run(c, cwd)   -- 需要交互（input() / pdb）时用真终端
  vim.cmd("botright 15new")
  vim.fn.jobstart(c, { term = true, cwd = cwd })
  vim.cmd.startinsert()
end

-- 检查 + 保存 + 收集上下文；失败返回 nil
local function py_ctx()
  if vim.bo.filetype ~= "python" then return vim.notify("当前不是 Python 文件", L.WARN) end
  local ok, err = try_cmd("silent update")
  if not ok then return vim.notify("保存失败: " .. tostring(err), L.ERROR) end
  local file = vim.api.nvim_buf_get_name(0)
  if file == "" or vim.fn.filereadable(file) == 0 then
    return vim.notify("当前文件还没保存到磁盘", L.WARN)
  end
  local root = py_root(0)
  local py = python_for(root)
  if not py then return vim.notify("找不到 Python 解释器（<Space>pv 手动指定）", L.ERROR) end
  return { file = file, root = root, py = py }
end

-- 光标所在的 test 函数（含外层 class）→ path::Class::test_name
local function nearest_test(file)
  local row = vim.api.nvim_win_get_cursor(0)[1]
  local lines = vim.api.nvim_buf_get_lines(0, 0, row, false)
  local parts, indent, start = {}, nil, nil
  for i = row, 1, -1 do
    local ind, name = lines[i]:match("^(%s*)async%s+def%s+(test[%w_]*)")
    if not name then ind, name = lines[i]:match("^(%s*)def%s+(test[%w_]*)") end
    if name then parts, indent, start = { name }, #ind, i; break end
  end
  if not start then return end
  for i = start - 1, 1, -1 do
    local ind = #lines[i]:match("^%s*")
    if lines[i]:match("%S") and ind < indent then
      local cls = lines[i]:match("^%s*class%s+([%w_]+)")
      if not cls then break end
      table.insert(parts, 1, cls); indent = ind
      if ind == 0 then break end
    end
  end
  return file .. "::" .. table.concat(parts, "::")
end

local function pytest(c, target, title)
  local argv = { c.py, "-m", "pytest", "-q", "--tb=line" }
  if target then table.insert(argv, target) end
  run_job({ name = title, cmd = argv, cwd = c.root, efm = PYTEST_EFM })
end

local function ruff_action(kind)
  if #vim.lsp.get_clients({ bufnr = 0, name = "ruff" }) == 0 then
    return vim.notify("ruff 未运行（需要安装 ruff）", L.WARN)
  end
  vim.lsp.buf.code_action({ context = { only = { kind }, diagnostics = {} }, apply = true })
end

-- 选择解释器：列出 $VIRTUAL_ENV、项目内各 venv、当前 conda 环境、conda base 及 envs/ 下所有环境、
-- PATH，以及（Windows）py 启动器登记的所有 Python
local function select_python()
  local root = py_root(0)
  local items, seen = {}, {}
  local function add(p, label)
    if p and not seen[p] then seen[p] = true; table.insert(items, { path = p, label = label }) end
  end
  add(venv_python(vim.env.VIRTUAL_ENV), "$VIRTUAL_ENV")
  for name, t in vim.fs.dir(root) do
    if t == "directory" or t == "link" then add(venv_python(vim.fs.joinpath(root, name)), name) end
  end
  add(venv_python(vim.env.CONDA_PREFIX), "conda 当前")
  if CONDA_BASE then
    add(venv_python(CONDA_BASE), "conda base")
    local envs = vim.fs.joinpath(CONDA_BASE, "envs")
    if vim.fn.isdirectory(envs) == 1 then
      for name, t in vim.fs.dir(envs) do
        if t == "directory" then add(venv_python(vim.fs.joinpath(envs, name)), "conda:" .. name) end
      end
    end
  end
  add(path_python(), "PATH")
  if IS_WIN and has("py") then   -- [Win] py -0p 列出所有已安装的 Python
    local ok, r = pcall(function() return vim.system({ "py", "-0p" }, { text = true }):wait(3000) end)
    for line in ((ok and r.stdout) or ""):gmatch("[^\r\n]+") do
      local p = line:match("(%a:[\\/].-%.exe)%s*$")
      if p then add(real_python(vim.fs.normalize(p)), "py 启动器") end
    end
  end
  table.insert(items, { label = "手动输入路径…" })

  local function apply(p)
    if vim.fn.executable(p) == 0 then return vim.notify("不可执行: " .. p, L.ERROR) end
    py_chosen[root] = p
    for _, cl in ipairs(vim.lsp.get_clients({ name = "basedpyright" })) do  -- 同项目的所有客户端
      if (cl.root_dir and vim.fs.normalize(cl.root_dir) == root) or vim.lsp.buf_is_attached(0, cl.id) then
        pyright_set_python(cl, p)
      end
    end
    vim.notify("Python 解释器: " .. p .. "\n（已打开的 REPL 需关闭后重开）")
  end

  vim.ui.select(items, {
    prompt = "Python 解释器（当前 " .. (python_for(root) or "无") .. "）",
    format_item = function(it) return it.path and ("%-14s %s"):format(it.label, it.path) or it.label end,
  }, function(it)
    if not it then return end
    if it.path then return apply(it.path) end
    vim.ui.input({ prompt = "python 路径: ", completion = "file" }, function(s)
      if s and s ~= "" then apply(vim.fs.normalize(s)) end
    end)
  end)
end

-- REPL：有 ipython 用 ipython（括号粘贴，多行块最稳）；否则普通 python，多行代码经临时文件 exec
-- [Win] ConPTY 下括号粘贴不可靠，Windows 上多行代码一律走临时文件 exec（ipython 也支持）
local repl = {}
local repl_toggle

local function repl_win() return repl.buf and vim.fn.bufwinid(repl.buf) or -1 end

local function repl_open()
  local buf_ok = repl.buf and vim.api.nvim_buf_is_valid(repl.buf)
  if repl.chan and buf_ok then
    if repl_win() == -1 then
      local cur = vim.api.nvim_get_current_win()
      vim.cmd("botright 15split")
      vim.api.nvim_win_set_buf(0, repl.buf)
      vim.api.nvim_set_current_win(cur)
    end
    return true
  end
  if buf_ok then vim.api.nvim_buf_delete(repl.buf, { force = true }) end   -- 清掉已退出的旧 REPL
  local root = py_root(0)
  local py = python_for(root)
  if not py then return vim.notify("找不到 Python 解释器", L.ERROR) end
  -- [Win] conda 环境里 python.exe 在根目录，ipython.exe 在 Scripts\ 下，两处都找
  local ipy
  for _, d in ipairs({ vim.fs.dirname(py), vim.fs.joinpath(vim.fs.dirname(py), "Scripts") }) do
    local p = vim.fs.joinpath(d, IS_WIN and "ipython.exe" or "ipython")
    if vim.uv.fs_stat(p) then ipy = p; break end
  end
  repl.ipython = ipy ~= nil
  local argv = ipy and { ipy, "--no-autoindent" } or { py, "-q" }
  local cur = vim.api.nvim_get_current_win()
  vim.cmd("botright 15new")
  repl.buf = vim.api.nvim_get_current_buf()
  repl.chan = vim.fn.jobstart(argv, { term = true, cwd = root,
                                      on_exit = function() repl.chan = nil end })
  -- REPL 窗口里也能用同一个键收起
  map("n", "<LocalLeader>pp", function() repl_toggle() end, { buffer = repl.buf, desc = "Toggle REPL" })
  vim.api.nvim_set_current_win(cur)
  return true
end

repl_toggle = function()
  local win = repl_win()
  if win ~= -1 then vim.api.nvim_win_close(win, false) else repl_open() end
end

local function dedent(lines)
  local min
  for _, l in ipairs(lines) do
    if l:match("%S") then local n = #l:match("^%s*"); min = math.min(min or n, n) end
  end
  return vim.tbl_map(function(l) return l:sub((min or 0) + 1) end, lines)
end

local function repl_send(lines)
  lines = dedent(lines)
  if not repl_open() then return end
  if #lines == 1 then
    vim.fn.chansend(repl.chan, lines[1] .. "\r")
  elseif repl.ipython and not IS_WIN then
    vim.fn.chansend(repl.chan, "\27[200~" .. table.concat(lines, "\n") .. "\27[201~\r\r")
  else
    local tmp = vim.fn.tempname() .. ".py"
    vim.fn.writefile(lines, tmp)
    vim.fn.chansend(repl.chan, ("exec(compile(open(%s, encoding='utf-8').read(), '<selection>', 'exec'))\r")
      :format(vim.json.encode(tmp)))
  end
  local win = repl_win()
  if win ~= -1 then vim.api.nvim_win_call(win, function() vim.cmd("normal! G") end) end
end

ft_keys("python", function(k)
  -- 运行
  k("n", "<LocalLeader>pr", function()
    local c = py_ctx(); if not c then return end
    run_job({ name = "Python " .. vim.fs.basename(c.file), cmd = { c.py, "-u", c.file },
              cwd = c.root, efm = PY_EFM })
  end, "Run file")
  k("n", "<LocalLeader>pa", function()
    local c = py_ctx(); if not c then return end
    vim.ui.input({ prompt = "参数: ", default = vim.b.py_args or "" }, function(s)
      if not s then return end
      vim.b.py_args = s
      local line = table.concat(vim.tbl_map(vim.fn.shellescape, { c.py, "-u", c.file }), " ") .. " " .. s
      run_job({ name = "Python " .. vim.fs.basename(c.file) .. " " .. s, cmd = line, cwd = c.root, efm = PY_EFM })
    end)
  end, "Run with args")
  k("n", "<LocalLeader>pw", function()   -- 项目内任意文件保存都会重跑；<Space>oa 停止
    local c = py_ctx(); if not c then return end
    run_job({ name = "Python 监视 " .. vim.fs.basename(c.file), cmd = { c.py, "-u", c.file },
              cwd = c.root, efm = PY_EFM, watch = c.root })
  end, "Rerun on save")
  k("n", "<LocalLeader>pd", function()   -- 配合 <Space>pb 插入的 breakpoint() 进 pdb
    local c = py_ctx(); if not c then return end
    term_run({ c.py, c.file }, c.root)
  end, "Run in terminal (interactive/pdb)")
  k("n", "<LocalLeader>pb", function()
    if not editable() then return end
    local row = vim.api.nvim_win_get_cursor(0)[1]
    local line = vim.api.nvim_get_current_line()
    if line:match("^%s*breakpoint%(%)%s*$") then
      vim.api.nvim_buf_set_lines(0, row - 1, row, false, {})
    else
      vim.api.nvim_buf_set_lines(0, row - 1, row - 1, false, { line:match("^%s*") .. "breakpoint()" })
    end
  end, "Toggle breakpoint()")

  -- 测试
  k("n", "<LocalLeader>pt", function()
    local c = py_ctx(); if not c then return end
    local id = nearest_test(c.file)
    if not id then return vim.notify("光标上方没有 test_ 函数", L.WARN) end
    pytest(c, id, "pytest " .. id:match("::(.*)$"))
  end, "Test nearest")
  k("n", "<LocalLeader>pf", function()
    local c = py_ctx(); if c then pytest(c, c.file, "pytest " .. vim.fs.basename(c.file)) end
  end, "Test file")
  k("n", "<LocalLeader>pT", function()
    local c = py_ctx(); if c then pytest(c, nil, "pytest 全部") end
  end, "Test all")

  -- ruff / 解释器 / REPL
  k("n", "<LocalLeader>pi", function() ruff_action("source.organizeImports.ruff") end, "Organize imports")
  k("n", "<LocalLeader>px", function() ruff_action("source.fixAll.ruff") end,         "Ruff fix all")
  k("n", "<LocalLeader>pv", select_python, "Select interpreter")
  k("n", "<LocalLeader>pp", function() repl_toggle() end, "Toggle REPL")
  k("n", "<LocalLeader>ps", function() repl_send({ vim.api.nvim_get_current_line() }) end, "Send line")
  k("x", "<LocalLeader>ps", function()
    local lines = vim.fn.getregion(vim.fn.getpos("v"), vim.fn.getpos("."), { type = vim.fn.mode() })
    vim.api.nvim_feedkeys(vim.keycode("<Esc>"), "nx", false)
    repl_send(lines)
  end, "Send selection")

  vim.opt_local.colorcolumn = tostring(USER.py_line_length + 1)
end)

-- 保存时用 ruff 格式化（全局开关，任何缓冲区都能切换）
vim.g.py_format_on_save = USER.py_format_on_save
map("n", "<leader>uf", function()
  vim.g.py_format_on_save = not vim.g.py_format_on_save
  vim.notify("Python 保存时格式化: " .. (vim.g.py_format_on_save and "开" or "关"))
end, { desc = "Toggle format on save (py)" })

au("LspAttach", {
  group = group,
  callback = function(args)
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    if not client or client.name ~= "ruff" then return end
    client.server_capabilities.hoverProvider = false      -- K 只用 basedpyright 的文档
    if vim.b[args.buf].py_fmt_au then return end          -- LSP 重启时别重复注册
    vim.b[args.buf].py_fmt_au = true
    au("BufWritePre", {
      group = group, buffer = args.buf,
      callback = function(e)
        if not vim.g.py_format_on_save or vim.b[e.buf].bigfile then return end
        if #vim.lsp.get_clients({ bufnr = e.buf, name = "ruff" }) == 0 then return end
        vim.lsp.buf.format({ bufnr = e.buf, name = "ruff", timeout_ms = 2000 })
      end,
    })
  end,
})

----------------------------------------------------------------------
-- 12. Go（与 Python 共用项目根、Overseer、quickfix 和文件类型局部键）
--     需要外部工具：go；语义补全/诊断/格式化需要 gopls（go install golang.org/x/tools/gopls@latest）
----------------------------------------------------------------------
local GO_EFM = [[%f:%l:%c: %m,%f:%l: %m]]

local function go_ctx()
  if vim.bo.filetype ~= "go" then return vim.notify("当前不是 Go 文件", L.WARN) end
  local ok, err = try_cmd("silent update")
  if not ok then return vim.notify("保存失败: " .. tostring(err), L.ERROR) end
  local file = vim.api.nvim_buf_get_name(0)
  if file == "" or vim.fn.filereadable(file) == 0 then
    return vim.notify("当前文件还没保存到磁盘", L.WARN)
  end
  local root = vim.fs.root(0, { "go.work", "go.mod", ".git" }) or vim.fs.dirname(file)
  local go = find_exe("go")
  if not go then return vim.notify("找不到 Go 工具链（go）", L.ERROR) end
  return { file = file, root = vim.fs.normalize(root), go = go }
end

-- 把当前文件所在目录转成 go test / go run 可接受的相对包路径。
local function go_package(c)
  local rel = vim.fs.relpath(c.root, vim.fs.dirname(c.file)) or "."
  rel = rel:gsub("\\\\", "/")
  if rel == "." or rel == "" then return "." end
  return "./" .. rel
end

local function nearest_go_test()
  local row = vim.api.nvim_win_get_cursor(0)[1]
  local lines = vim.api.nvim_buf_get_lines(0, 0, row, false)
  for i = row, 1, -1 do
    local line = lines[i]
    local name = line:match("^%s*func%s+([A-Z][%w_]*)%s*%(")
      or line:match("^%s*func%s*%([^)]*%)%s*([A-Z][%w_]*)%s*%(")
    if name and (name:match("^Test") or name:match("^Benchmark") or name:match("^Example")) then
      return name
    end
  end
end

local function go_run(c, args, title)
  run_job({ name = title, cmd = vim.list_extend({ c.go }, args), cwd = c.root, efm = GO_EFM })
end

vim.g.go_format_on_save = USER.go_format_on_save
map("n", "<leader>uG", function()
  vim.g.go_format_on_save = not vim.g.go_format_on_save
  vim.notify("Go 保存时格式化: " .. (vim.g.go_format_on_save and "开" or "关"))
end, { desc = "Toggle format on save (go)" })

ft_keys("go", function(k)
  k("n", "<LocalLeader>gr", function()
    local c = go_ctx(); if c then go_run(c, { "run", go_package(c) }, "Go run " .. vim.fs.basename(c.file)) end
  end, "Run package")
  k("n", "<LocalLeader>gt", function()
    local c = go_ctx(); if not c then return end
    local name = nearest_go_test()
    if not name then return vim.notify("光标上方没有 Test/Benchmark/Example 函数", L.WARN) end
    go_run(c, { "test", "-count=1", "-run", "^" .. name .. "$", go_package(c) }, "Go test " .. name)
  end, "Test nearest")
  k("n", "<LocalLeader>gf", function()
    local c = go_ctx(); if c then go_run(c, { "test", "-count=1", go_package(c) }, "Go test " .. vim.fs.basename(c.file)) end
  end, "Test package")
  k("n", "<LocalLeader>gT", function()
    local c = go_ctx(); if c then go_run(c, { "test", "-count=1", "./..." }, "Go test all") end
  end, "Test all")
  k("n", "<LocalLeader>gb", function()
    local c = go_ctx(); if c then go_run(c, { "build", "./..." }, "Go build") end
  end, "Build all")
  k("n", "<LocalLeader>gF", function()
    local c = go_ctx(); if not c then return end
    if #vim.lsp.get_clients({ bufnr = 0, name = "gopls" }) > 0 then
      vim.lsp.buf.format({ bufnr = 0, name = "gopls", timeout_ms = 2000 })
    else
      go_run(c, { "fmt", go_package(c) }, "Go format")
    end
  end, "Format package")
  k("n", "<LocalLeader>gi", function()
    if #vim.lsp.get_clients({ bufnr = 0, name = "gopls" }) == 0 then
      return vim.notify("gopls 未运行，无法自动整理 import", L.WARN)
    end
    vim.lsp.buf.code_action({ context = { only = { "source.organizeImports" }, diagnostics = {} }, apply = true })
  end, "Organize imports")
end)

-- gopls 的格式化策略和 Python/ruff 一样：每个 buffer 只注册一次保存钩子。
au("LspAttach", {
  group = group,
  callback = function(args)
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    if not client or client.name ~= "gopls" or vim.b[args.buf].go_fmt_au then return end
    vim.b[args.buf].go_fmt_au = true
    au("BufWritePre", {
      group = group, buffer = args.buf,
      callback = function(e)
        if not vim.g.go_format_on_save or vim.b[e.buf].bigfile then return end
        if #vim.lsp.get_clients({ bufnr = e.buf, name = "gopls" }) == 0 then return end
        vim.lsp.buf.format({ bufnr = e.buf, name = "gopls", timeout_ms = 2000 })
      end,
    })
  end,
})

----------------------------------------------------------------------
-- 13. Neovide（缩放键沿用 Neovide 官方 FAQ 的写法）
----------------------------------------------------------------------
o.guifont = ("%s:h%d"):format(USER.font, USER.font_size)

if vim.g.neovide then
  o.linespace = 2
  vim.g.neovide_padding_top, vim.g.neovide_padding_bottom = 8, 8
  vim.g.neovide_padding_left, vim.g.neovide_padding_right = 8, 8
  vim.g.neovide_refresh_rate, vim.g.neovide_refresh_rate_idle = 60, 5
  vim.g.neovide_scroll_animation_length = 0.1
  vim.g.neovide_scroll_animation_far_lines = 0
  vim.g.neovide_cursor_animation_length = 0.05
  vim.g.neovide_cursor_trail_size = 0.1
  vim.g.neovide_cursor_vfx_mode = ""
  vim.g.neovide_opacity = 0.985
  vim.g.neovide_window_blurred = true
  vim.g.neovide_floating_blur_amount_x, vim.g.neovide_floating_blur_amount_y = 1.0, 1.0
  vim.g.neovide_scale_factor = 1.0
  local function scale(f) vim.g.neovide_scale_factor = f and vim.g.neovide_scale_factor * f or 1.0 end
  map("n", "<C-=>", function() scale(1.1) end,     { desc = "Zoom in" })
  map("n", "<C-->", function() scale(1 / 1.1) end, { desc = "Zoom out" })
  map("n", "<C-0>", function() scale(nil) end,     { desc = "Zoom reset" })
end

----------------------------------------------------------------------
-- 14. 缺失插件汇总提示（只提示一次）
----------------------------------------------------------------------
if #missing > 0 then
  vim.schedule(function()
    local hints = { "修复后重启 nvim 会自动安装" }
    if not has("git") then
      table.insert(hints, 1, IS_WIN and "未找到 git：vim.pack 需要 git（winget install Git.Git）"
                                    or  "未找到 git：vim.pack 需要 git 才能安装插件")
    end
    if not MIRROR then
      table.insert(hints, IS_WIN
        and "国内网络可设置镜像（cmd / PowerShell）: setx NVIM_PACK_MIRROR https://ghfast.top/  然后重开终端"
        or  "国内网络可设置镜像: export NVIM_PACK_MIRROR=https://ghfast.top/")
    end
    vim.notify(("以下插件未加载，相关功能已跳过，编辑器可正常使用:\n  %s\n%s")
      :format(table.concat(missing, ", "), table.concat(hints, "\n")), L.WARN)
  end)
end
