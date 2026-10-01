-- ~/.config/nvim/init.lua  (仅支持 Neovim 0.12+)
--
-- ╔══════════════════════════════ PLUGINS ══════════════════════════════════
-- ║ 插件共 3 个: mini.nvim / multicursor.nvim / overseer.nvim
-- ║ 首次启动由内置 vim.pack 自动安装（需要 git）；版本记录在 nvim-pack-lock.json
-- ║ 任一插件缺失时自动跳过相关功能，启动后汇总提示一次
-- ║ 国内网络: export NVIM_PACK_MIRROR=https://ghfast.top/    预装: nvim --headless +qa
-- ║ :PackUpdate [名字…] 更新   :PackSync 按锁文件同步   :PackClean 删除不用的插件
-- ╚═════════════════════════════════════════════════════════════════════════
--
-- ╔══════════════════════════════ CHEATSHEET ═════════════════════════════
-- ║ <Space> 为 Leader。按下 <Space> g z [ ] ' " <C-w> 后停顿会弹出按键提示
-- ╟─ 文件 / 查找 / 缓冲区 ─────────────────────────────────────────────────
-- ║ <C-s> 保存  <Space>w 写入  <Space>q 退出  <Space>bd 关缓冲区(保留窗口)  - 浏览目录
-- ║ <Space>ff 文件  fg 全文  fb 缓冲区  fo 最近  fh 帮助  fl 当前文件行  fd 诊断  fr 恢复
-- ║ <Space>cd 切到文件目录(暂停自动切换)   <Space>cr 回项目根(恢复自动切换)
-- ╟─ 包围 / 文本对象 ──────────────────────────────────────────────────────
-- ║ ysiw" 加包围  yss) 整行  可视 S( 选区  ds( 删除  cs"' 替换  (t=标签 f=函数)
-- ║ 文本对象(mini.ai): f=函数调用 a=参数 t=标签 q=引号 b=括号
-- ╟─ 多光标（只用 Q；与 Neovim 0.13 内置多光标同键） ─────────────────────
-- ║ Q 放置/删除光标  5Q 在后 5 个搜索匹配处加光标  gQ 找回刚清除的光标
-- ║ 有多光标时: <Esc> 恢复暂停的光标 / 清除所有光标
-- ║ 注意: Q 不再重放宏，改用 @@（录制后首次用 @q）
-- ╟─ 任务 / LaTeX ─────────────────────────────────────────────────────────
-- ║ <Space>or 运行  oo 面板  ol 重跑最近  oa 操作  os shell 命令
-- ║ <Space>tt 编译  tw 持续编译  te 完全重建  tc 清理  tv 打开 PDF
-- ╟─ Python ───────────────────────────────────────────────────────────────
-- ║ <Space>pr 运行  pa 带参数  pw 保存即重跑  pd 终端运行(交互/pdb)  pb 切换 breakpoint()
-- ║ <Space>pt 最近测试  pf 本文件  pT 全部   pi 整理 import  px ruff 修复  pv 选解释器
-- ║ <Space>pp REPL  ps 发送行/选区   <Space>cf 格式化(ruff)  <Space>uf 保存时格式化
-- ╟─ LSP / 诊断 / Git（大多为 0.12 内置键） ─────────────────────────────
-- ║ gd 定义  K 文档  grn 重命名  gra 代码操作  grr 引用  gri 实现  grt 类型定义  gO 符号
-- ║ <Space>cf 格式化   插入模式 <M-s> 签名帮助   [d ]d 诊断(自动弹窗)  <C-w>d 诊断浮窗
-- ║ ]h [h 修改块  ghgh 暂存  gHgh 撤销  <Space>go 差异  <Space>gs 提交信息
-- ╟─ 开关 / 其他 ──────────────────────────────────────────────────────────
-- ║ <Space>uu 撤销树  uh 内联提示  uw 保存时去行尾空白  uf 保存时格式化   F9 深浅色  F10 拼写
-- ║ gc/gcc 注释  <M-j>/<M-k> 移动行  <C-h/j/k/l> 切窗口  \ 替换光标词
-- ║ 终端 <Esc><Esc> 回普通模式   插入 <M-d> 时间   F11 分隔线  F12 文件头
-- ╚═════════════════════════════════════════════════════════════════════════

-- 0.12是推动开箱即用OOTB的里程碑版本
if vim.fn.has("nvim-0.12") == 0 then
  vim.api.nvim_echo({ { "此配置需要 Neovim 0.12+，已停止加载", "ErrorMsg" } }, true, {})
  return
end

----------------------------------------------------------------------
-- 个人设置：别人使用这份配置时，通常只需要改这里
----------------------------------------------------------------------
local USER = {
  author       = nil,                        -- F12 文件头作者；nil = 自动读取 git config user.name
  mirror       = vim.env.NVIM_PACK_MIRROR,   -- GitHub 镜像，例 "https://ghfast.top/"；nil = 直连
  colorscheme  = "retrobox",                 -- 内置备选: default / habamax / unokai
  background   = "dark",                     -- "dark" / "light"（F9 可临时切换）
  font         = "Hack",                     -- GUI（Neovide）字体
  font_size    = 14,
  indent       = 4,                          -- 缩进宽度（空格）
  width        = 80,                         -- 参考线位置(第 width+1 列) 与 F11/F12 装饰宽度
  clipboard    = "unnamedplus",              -- 与系统剪贴板同步；设为 "" 则不同步
  auto_cd      = true,                       -- 打开文件时自动切换到项目根目录
  -- 项目根标记：同一层 { } 内优先级相同（取最近的），monorepo 子包优先于 .git
  root_markers = { { "Makefile", "justfile", "package.json", "pyproject.toml",
                     "Cargo.toml", "pubspec.yaml" }, ".git", ".vscode" },
  trim_on_save = true,                       -- 保存时去行尾空白（<Space>uw 按缓冲区切换）
  ui2          = true,                       -- 0.12 实验性新消息/命令行界面（无 Press ENTER）
  autocomplete = true,                       -- 0.12 原生自动补全（无 LSP 的文件也会弹）
  inlay_hints  = false,                      -- LSP 内联类型提示默认开关（<Space>uh 切换）
  latex_engine = "-xelatex",                 -- latexmk 引擎: -xelatex / -lualatex / -pdf
  pdf_viewers  = { "okular", "evince", "zathura" },  -- 按顺序尝试，都没有就用系统默认程序
  bigfile_mb   = 5,                          -- 超过此大小：关高亮 / 折叠 / LSP / diff / undo 文件
  -- PATH 里找不到 LSP / ruff 时，再到这些目录找（conda base 的 bin 会自动加入）
  -- 用途：conda activate 到别的环境、或从桌面菜单启动 Neovide 时 PATH 不完整
  extra_path   = { "~/.local/bin" },
  python            = nil,                   -- 强制指定解释器路径；nil = 自动探测（见第 9 节）
  py_typecheck      = "standard",            -- basedpyright: off / basic / standard / strict / recommended / all
  py_format_on_save = true,                  -- 有 ruff 时保存自动格式化（<Space>uf 切换）
  py_line_length    = 88,                    -- Python 参考线位置（ruff/black 默认 88）
}

vim.g.mapleader      = " "
vim.g.maplocalleader = " "

local map   = vim.keymap.set
local L     = vim.log.levels
local o     = vim.o
local au    = vim.api.nvim_create_autocmd
local group = vim.api.nvim_create_augroup("UserConfig", { clear = true })
local function has(exe) return vim.fn.executable(exe) == 1 end

-- ui2 尽早启用，让后面的启动消息也走新界面
if USER.ui2 then pcall(function() require("vim._core.ui2").enable({}) end) end

----------------------------------------------------------------------
-- 0. 插件 (vim.pack)
----------------------------------------------------------------------
local PLUGINS = {
  { src = "https://github.com/nvim-mini/mini.nvim" },
  { src = "https://github.com/jake-stewart/multicursor.nvim", version = "1.0" }, -- 作者要求用 1.0 分支
  { src = "https://github.com/stevearc/overseer.nvim" },
}
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
  local env = { GIT_TERMINAL_PROMPT = "0", GIT_CONFIG_COUNT = tostring(base + #cfg) } -- 不弹密码提示卡住启动
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
    if vim.fn.isdirectory(PACK_DIR .. pname(spec)) == 1 then pcall(vim.cmd, "packadd! " .. pname(spec)) end
  end
end

local function pack_run(msg, fn)
  vim.notify(msg .. (MIRROR and ("（经镜像 " .. MIRROR .. "）") or "") .. " ...")
  local ok, err = with_git_env(fn)
  if not ok then vim.notify("失败: " .. tostring(err), L.ERROR) end
  -- 会打开确认页：:write 应用，:quit 放弃；应用后 :restart 生效
end

vim.api.nvim_create_user_command("PackUpdate", function(a)
  pack_run("正在检查插件更新", function() vim.pack.update(#a.fargs > 0 and a.fargs or nil) end)
end, { nargs = "*", desc = "Update plugins",
       complete = function() return vim.tbl_map(pname, PLUGINS) end })

-- 换机器 / 回滚：把插件恢复到 nvim-pack-lock.json 记录的版本
vim.api.nvim_create_user_command("PackSync", function()
  pack_run("正在按锁文件同步插件", function() vim.pack.update(nil, { target = "lockfile" }) end)
end, { desc = "Sync plugins to lockfile" })

vim.api.nvim_create_user_command("PackClean", function()
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
o.signcolumn   = "yes"
o.scrolloff    = 4
o.colorcolumn  = tostring(USER.width + 1)
o.list         = true
o.listchars    = "tab:│ ,trail:·,nbsp:."
o.winborder    = "rounded"
pcall(function() o.pumborder = "rounded" end)         -- 0.12：补全菜单边框

o.wrap, o.linebreak, o.breakindent = true, true, true
o.whichwrap    = "b,s,<,>,[,],h,l"

o.expandtab = true
o.shiftwidth, o.tabstop, o.softtabstop = USER.indent, USER.indent, USER.indent
o.shiftround = true

o.ignorecase, o.smartcase = true, true

o.undofile      = true
o.confirm       = true
o.fileencodings = "ucs-bom,utf-8,gb18030,latin1"   -- Big5 文件请手动 :e ++enc=big5
o.spelllang     = "en_us,cjk"                       -- 拼写检查时不把中日韩文字标红

-- 默认按缩进折叠；有 treesitter 解析器或 LSP foldingRange 时自动换成更准的（见第 8、9 节）
o.foldmethod, o.foldlevel = "indent", 99

o.timeoutlen   = 400
o.switchbuf    = "useopen,uselast"
o.splitright, o.splitbelow = true, true

-- 插入模式补全：0.12 原生自动补全；有 LSP 的缓冲区改由 LSP 自动补全接管（第 9 节）
o.completeopt  = "menu,menuone,noselect,popup,fuzzy"
o.autocomplete = USER.autocomplete

-- 命令行补全：0.12 的 wildtrigger() 实现边输入边弹出菜单（: / ? 都有效）
o.path        = o.path .. ",**"
-- 【新】加入 Python 缓存 / 虚拟环境目录
o.wildignore  = "*/node_modules/*,*/.git/*,*/target/*,*/dist/*,*.o,*.pyc,"
             .. "*/__pycache__/*,*/.venv/*,*/.mypy_cache/*,*/.ruff_cache/*,*/.pytest_cache/*"
o.wildoptions = "pum,fuzzy"
if vim.fn.exists("*wildtrigger") == 1 and pcall(function() o.wildmode = "noselect:lastused,full" end) then
  au("CmdlineChanged", { group = group, pattern = { ":", "/", "?" },
                         callback = function() vim.fn.wildtrigger() end })
  -- 菜单弹出时 <Up>/<Down> 仍用于翻命令历史
  map("c", "<Up>",   function() return vim.fn.wildmenumode() == 1 and "<C-e><Up>"   or "<Up>"   end, { expr = true })
  map("c", "<Down>", function() return vim.fn.wildmenumode() == 1 and "<C-e><Down>" or "<Down>" end, { expr = true })
else
  o.wildmode = "longest:full,full"
end

o.formatlistpat = [[^\s*\(\d\+\|[-*]\)\+[\]:.)}\t ]\s*]]
vim.opt.formatoptions:append("n")

-- 剪贴板延后设置：检测剪贴板工具可能较慢（SSH / WSL），不拖慢启动
vim.schedule(function() o.clipboard = USER.clipboard end)

vim.g.netrw_banner, vim.g.netrw_liststyle = 0, 3

----------------------------------------------------------------------
-- 2. 主题
----------------------------------------------------------------------
o.background = USER.background
if not pcall(vim.cmd.colorscheme, USER.colorscheme) then
  vim.notify(("配色 %s 不存在，已使用默认配色"):format(USER.colorscheme), L.WARN)
end
map("n", "<F9>", function()
  o.background = o.background == "dark" and "light" or "dark"
  vim.notify("背景: " .. o.background)
end, { desc = "Toggle dark/light" })

----------------------------------------------------------------------
-- 3. mini.nvim
----------------------------------------------------------------------
-- 通知用浮窗显示；历史记录：:lua MiniNotify.show_history()
use("mini.notify", function(m)
  m.setup()
  vim.notify = m.make_notify()
end)

use("mini.starter",    function(m) m.setup() end)
use("mini.pairs",      function(m) m.setup() end)
use("mini.ai",         function(m) m.setup({ n_lines = 500 }) end)
use("mini.statusline", function(m) m.setup({ use_icons = false }) end)

use("mini.bufremove", function(m)
  m.setup()
  map("n", "<leader>bd", function() m.delete() end, { desc = "Delete buffer (keep window)" })
end)

use("mini.git", function(m)
  m.setup()
  map({ "n", "x" }, "<leader>gs", function() m.show_at_cursor() end, { desc = "Git at cursor" })
end)

use("mini.diff", function(m)
  m.setup({ view = { style = "sign" } })
  map("n", "<leader>go", function() m.toggle_overlay() end, { desc = "Diff overlay" })
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
  map("n", "<leader>fb", function() b.buffers() end, { desc = "Buffers" })
  map("n", "<leader>fh", function() b.help() end,    { desc = "Help" })
  map("n", "<leader>fr", function() b.resume() end,  { desc = "Resume" })
end)

use("mini.extra", function(m)
  m.setup()
  if not pick then return end
  map("n", "<leader>fo", function() m.pickers.oldfiles() end,   { desc = "Recent files" })
  map("n", "<leader>fd", function() m.pickers.diagnostic() end, { desc = "Diagnostics" })
  map("n", "<leader>fl", function() m.pickers.buf_lines({ scope = "current" }) end, { desc = "Buffer lines" })
end)

if not pick then   -- 降级：内置命令（'path' 已含 **）
  map("n", "<leader>ff", ":find ",                   { desc = "Files (builtin)" })
  map("n", "<leader>fg", ":vimgrep //gj **" .. ("<Left>"):rep(6), { desc = "Grep (builtin)" })
  map("n", "<leader>fb", ":ls<cr>:b ",               { desc = "Buffers (builtin)" })
  map("n", "<leader>fh", ":help ",                   { desc = "Help (builtin)" })
  map("n", "<leader>fo", "<cmd>browse oldfiles<cr>", { desc = "Recent files (builtin)" })
  map("n", "<leader>fd", vim.diagnostic.setloclist,  { desc = "Diagnostics (builtin)" })
end

-- 包围：vim-surround 风格 ys / ds / cs。原生 Vim 里这三个组合本来就无效，不占任何内置键
use("mini.surround", function(m)
  m.setup({
    mappings = {
      add = "ys", delete = "ds", replace = "cs",
      find = "", find_left = "", highlight = "", update_n_lines = "",
      suffix_last = "", suffix_next = "",
    },
    custom_surroundings = {   -- 左括号也不加内侧空格
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
use("mini.clue", function(clue)
  local gen = clue.gen_clues
  clue.setup({
    triggers = {
      { mode = "n", keys = "<Leader>" }, { mode = "x", keys = "<Leader>" },
      { mode = "n", keys = "g" },        { mode = "x", keys = "g" },
      { mode = "n", keys = "z" },        { mode = "x", keys = "z" },
      { mode = "n", keys = "[" },        { mode = "n", keys = "]" },
      { mode = "n", keys = "<C-w>" },
      { mode = "n", keys = "'" },        { mode = "n", keys = "`" },   -- 标记
      { mode = "x", keys = "'" },        { mode = "x", keys = "`" },
      { mode = "n", keys = '"' },        { mode = "x", keys = '"' },   -- 寄存器
      { mode = "i", keys = "<C-r>" },    { mode = "c", keys = "<C-r>" },
      { mode = "i", keys = "<C-x>" },                                   -- 内置补全
    },
    clues = {
      gen.builtin_completion(), gen.g(), gen.marks(), gen.registers(), gen.windows(), gen.z(),
      { mode = "n", keys = "<Leader>b", desc = "+Buffer" },
      { mode = "n", keys = "<Leader>c", desc = "+Code / 目录" },
      { mode = "n", keys = "<Leader>f", desc = "+Find" },
      { mode = "n", keys = "<Leader>g", desc = "+Git" },
      { mode = "n", keys = "<Leader>o", desc = "+Overseer" },
      { mode = "n", keys = "<Leader>p", desc = "+Python" },          -- 【新】
      { mode = "x", keys = "<Leader>p", desc = "+Python" },          -- 【新】
      { mode = "n", keys = "<Leader>t", desc = "+LaTeX" },
      { mode = "n", keys = "<Leader>u", desc = "+Toggle / UI" },
    },
    window = { delay = 300 },
  })
end)

----------------------------------------------------------------------
-- 4. 多光标：只用 Q / gQ（与 Neovim 0.13 内置多光标同键，升级后手感不变）
--    不占用 <Leader>、Ctrl、Alt 组合；ga、<C-n>/<C-p>、可视 I/A/s 都保持原生功能。
--    在 0.13+ 上，这里的 Q / gQ 会覆盖内置同名键，内置的 <C-LeftMouse> 改回普通点击，
--    内置的 <C-l>（清除光标）已被第 6 节的切窗口覆盖，保证始终只有一套多光标。
--    代价：Q 不再重放宏（改用 @@），0.12 的 gQ（Ex 模式）也不再可用。
--    放在 mini.clue 之后：部分 mini.clue 版本会自己映射 Q（用于重放宏），这里要覆盖它。
----------------------------------------------------------------------
use("multicursor-nvim", function(mc)
  mc.setup()

  -- Q：无计数 = 在主光标处放置/删除光标（同时暂停其他光标，移到下一处再按 Q；<Esc> 恢复）
  --    [count]Q = 在接下来 count 个搜索匹配处加光标（先 /pattern）
  map("n", "Q", function()
    local n = vim.v.count
    if n == 0 then return mc.toggleCursor() end
    if vim.fn.getreg("/") == "" then return vim.notify("还没有搜索过，先用 /pattern 搜索", L.WARN) end
    for _ = 1, n do mc.searchAddCursor(1) end
  end, { desc = "Toggle cursor / [count] add at search" })
  map("x", "Q", function() mc.toggleCursor() end, { desc = "Toggle cursor" })
  map("n", "gQ", function() mc.restoreCursors() end, { desc = "Restore cleared cursors" })

  -- 仅在存在多光标时生效
  mc.addKeymapLayer(function(set)
    set("n", "<Esc>", function()
      if not mc.cursorsEnabled() then mc.enableCursors() else mc.clearCursors() end
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

----------------------------------------------------------------------
-- 5. Overseer (v2)
----------------------------------------------------------------------
-- 自定义组件：任务一启动就通知 (OverseerRun / OverseerShell / 重跑 / LaTeX / Python 都会触发)
package.preload["overseer.component.on_start_notify"] = function()
  return {
    desc = "vim.notify when task starts",
    constructor = function()
      return {
        on_start = function(_, task)
          local cmd = type(task.cmd) == "table" and table.concat(task.cmd, " ") or tostring(task.cmd)
          if vim.fn.strcharlen(cmd) > 70 then cmd = vim.fn.strcharpart(cmd, 0, 67) .. "…" end
          vim.schedule(function()
            vim.notify(("▶ %s\n  %s\n  <Space>oo 查看输出"):format(task.name, cmd))
          end)
        end,
      }
    end,
  }
end

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
-- 6. 通用快捷键
----------------------------------------------------------------------
map("n", "<Esc>", "<cmd>nohlsearch<cr><Esc>")          -- 有多光标时由上面的按键层接管
map({ "n", "x" }, "<C-z>", ":")                        -- 注意：占用了内置的挂起 (可用 :suspend)
map("i", "<C-z>", "<C-o>:")
map("n", "<C-F4>", "<C-w>c")
map("i", "<C-F4>", "<Esc><C-w>c")
map("c", "<C-F4>", "<C-c><C-w>c")
map("t", "<Esc><Esc>", [[<C-\><C-n>]], { desc = "Exit terminal mode" })

-- 保存：无名缓冲区 / 只读等错误给出提示，而不是一串报错
local function save(cmd)
  if vim.api.nvim_buf_get_name(0) == "" then
    return vim.notify("缓冲区还没有文件名，请用 :w 文件名 保存", L.WARN)
  end
  local ok, err = pcall(vim.cmd, cmd)
  if not ok then vim.notify((tostring(err):gsub("^Vim%(%a+%):", "")), L.ERROR) end
end
map("n", "<leader>w", function() save("write") end, { desc = "Write" })
map("n", "<leader>q", "<cmd>q<cr>", { desc = "Quit" })
map({ "n", "x", "i" }, "<C-s>", function() save("update") end, { desc = "Save" })  -- 插入模式签名帮助改到 <M-s>

-- 文件浏览：优先 netrw；netrw 被禁用时直接打开所在目录
map("n", "-", function()
  if vim.fn.exists(":Explore") == 2 then vim.cmd("Explore") else vim.cmd.edit(vim.fn.expand("%:p:h")) end
end, { desc = "File explorer" })

map({ "n", "x" }, "j", "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })
map({ "n", "x" }, "k", "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
map({ "n", "x" }, "<Down>", "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })
map({ "n", "x" }, "<Up>",   "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
map("i", "<Down>", [[pumvisible() ? "\<Down>" : "\<C-o>gj"]], { expr = true })  -- 补全菜单中仍用于选择
map("i", "<Up>",   [[pumvisible() ? "\<Up>"   : "\<C-o>gk"]], { expr = true })
map({ "n", "x" }, "<Home>", "^")
map({ "n", "x" }, "<End>",  "$")
map("n", "<PageUp>", "{")
map("n", "<PageDown>", "}")

map("n", "\\", [[:%s/\<<C-r><C-w>\>//gc<Left><Left><Left>]], { desc = "Replace word" })
map("n", "<F10>", function()
  vim.wo.spell = not vim.wo.spell
  vim.notify("拼写检查: " .. (vim.wo.spell and "开" or "关"))
end, { desc = "Toggle spell" })

map("i", "<C-BS>", "<C-w>")
map("i", "<C-Del>", "<C-o>dw")

map("n", "<C-h>", "<C-w>h")
map("n", "<C-j>", "<C-w>j")
map("n", "<C-k>", "<C-w>k")
map("n", "<C-l>", "<C-w>l")

-- 移动行：到首/尾行时静默不动，不报 E16
map("n", "<M-j>", "<cmd>silent! move .+1<cr>==")
map("n", "<M-k>", "<cmd>silent! move .-2<cr>==")
map("x", "<M-j>", ":<C-u>silent! '<,'>move '>+1<cr>gv=gv", { silent = true })
map("x", "<M-k>", ":<C-u>silent! '<,'>move '<-2<cr>gv=gv", { silent = true })
map("x", "p", "P")
map("x", "P", "p")

-- 插入时间 (<C-d> 保留给内置的"减少缩进")
map("i", "<M-d>", function() return os.date("%Y-%m-%d %H:%M:%S") end, { expr = true, desc = "Insert datetime" })
map("i", "<M-=>", "<Esc>A;<CR>")
map("i", "<M-->", "<Esc>A:<CR>")

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

-- 0.12 自带的可选插件：撤销树 / 目录对比 (:DiffTool dir1 dir2)
if pcall(vim.cmd.packadd, "nvim.undotree") and vim.fn.exists(":Undotree") == 2 then
  map("n", "<leader>uu", "<cmd>Undotree<cr>", { desc = "Undo tree" })
end
pcall(vim.cmd.packadd, "nvim.difftool")

map("n", "<leader>uh", function()
  local on = not vim.lsp.inlay_hint.is_enabled({ bufnr = 0 })
  vim.lsp.inlay_hint.enable(on, { bufnr = 0 })
  vim.notify("内联提示: " .. (on and "开" or "关"))
end, { desc = "Toggle inlay hints" })

----------------------------------------------------------------------
-- 7. 注释装饰 (F11 分隔线 / F12 文件头)
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
end

map({ "n", "i" }, "<F11>", function()
  if not editable() then return end
  local row = vim.api.nvim_win_get_cursor(0)[1]
  local insert = vim.api.nvim_get_mode().mode:sub(1, 1) == "i"
  local blank = vim.trim(vim.api.nvim_get_current_line()) == ""
  local start = (not insert and blank) and row - 1 or row   -- 普通模式空行：直接替换该行
  vim.api.nvim_buf_set_lines(0, start, row, false, { rule_line(DECO.rule) })
  vim.api.nvim_win_set_cursor(0, { start + 1, 0 })
end, { desc = "Separator line" })

map({ "n", "i" }, "<F12>", function()
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
end, { desc = "File header" })

----------------------------------------------------------------------
-- 8. 自动命令
----------------------------------------------------------------------
au("TextYankPost", { group = group, callback = function() vim.hl.on_yank({ timeout = 200 }) end })

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
-- <Space>cd 手动切到文件目录并暂停自动切换；<Space>cr 回到项目根并恢复
vim.g.auto_cd = USER.auto_cd
local home = vim.fs.normalize(vim.uv.os_homedir() or "")

local function project_root(buf)
  local name = vim.api.nvim_buf_get_name(buf)
  if vim.bo[buf].buftype ~= "" or name == "" or name:find("://", 1, true) then return end  -- 虚拟缓冲区
  local root = vim.fs.root(buf, USER.root_markers)
  if not root or root == home then root = vim.fs.dirname(name) end  -- 家目录是 dotfiles 仓库时不切到 ~
  return root
end

local function cd(dir)
  if dir and dir ~= vim.fs.normalize(vim.fn.getcwd()) and vim.fn.isdirectory(dir) == 1 then
    pcall(vim.fn.chdir, dir)
  end
end

au("BufEnter", {
  group = group,
  callback = function(args) if vim.g.auto_cd then cd(project_root(args.buf)) end end,
})

map("n", "<leader>cd", function()
  vim.g.auto_cd = false
  cd(vim.fn.expand("%:p:h"))
  vim.notify("cwd: " .. vim.fn.getcwd() .. "\n已暂停自动切换（<Space>cr 恢复）")
end, { desc = "cd to file dir (pause auto)" })
map("n", "<leader>cr", function()
  vim.g.auto_cd = true
  cd(project_root(0))
  vim.notify("cwd: " .. vim.fn.getcwd() .. "\n已恢复自动切换项目根目录")
end, { desc = "cd to project root (resume auto)" })

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
      vim.bo[args.buf].undofile = false
      vim.bo[args.buf].swapfile = false
      vim.notify(("大文件 (>%dMB)：已关闭高亮 / 折叠 / LSP / diff / undo 文件"):format(USER.bigfile_mb))
    end
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
        if vim.api.nvim_get_current_buf() == buf then
          local wo = vim.wo[0][0]
          wo.foldmethod, wo.cursorcolumn = "manual", false
        end
      end)
      return
    end
    local lang = vim.treesitter.language.get_lang(args.match)
    local ok, added = pcall(vim.treesitter.language.add, lang or "")
    if lang and ok and added and pcall(vim.treesitter.start, buf, lang)
      and vim.api.nvim_get_current_buf() == buf then
      local wo = vim.wo[0][0]
      wo.foldmethod, wo.foldexpr = "expr", "v:lua.vim.treesitter.foldexpr()"
    end
  end,
})

----------------------------------------------------------------------
-- 9. LSP (vim.lsp.config / enable)
--    内置默认键：K grn gra grr gri grt gO  [d ]d  <C-w>d；这里只补 gd / 格式化 / 签名帮助
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

local IS_WIN  = vim.fn.has("win32") == 1

-- conda 安装位置：优先 $CONDA_EXE（conda init 设置，切换环境后仍指向 base），
-- 没有（如从桌面启动）时查常见安装路径
local CONDA_BASE = (function()
  local exe = vim.env.CONDA_EXE
  if exe and exe ~= "" then return vim.fs.dirname(vim.fs.dirname(vim.fs.normalize(exe))) end
  for _, d in ipairs({ "~/miniconda3", "~/miniforge3", "~/anaconda3",
                       "/opt/miniconda3", "/opt/miniforge3", "/opt/anaconda3" }) do
    d = vim.fs.normalize(d)
    if vim.uv.fs_stat(vim.fs.joinpath(d, "condabin")) then return d end
  end
end)()

-- 外部工具查找：先 PATH，再 USER.extra_path，最后 conda base 的 bin
local TOOL_DIRS = vim.tbl_map(vim.fs.normalize, vim.deepcopy(USER.extra_path or {}))
if CONDA_BASE then table.insert(TOOL_DIRS, vim.fs.joinpath(CONDA_BASE, IS_WIN and "Scripts" or "bin")) end

local function find_exe(exe)
  if has(exe) then return exe end
  for _, d in ipairs(TOOL_DIRS) do
    local p = vim.fs.joinpath(d, exe .. (IS_WIN and ".exe" or ""))
    if has(p) then return p end
  end
end

-- Python 解释器探测（basedpyright / 运行 / 测试 / REPL 共用）
-- 优先级：<Space>pv 手选 > USER.python > $VIRTUAL_ENV > 项目内 .venv/venv/env
--         > $CONDA_PREFIX（当前激活的 conda 环境）> conda base > PATH
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

local function py_root(buf)
  local name = vim.api.nvim_buf_get_name(buf or 0)
  return vim.fs.root(buf or 0, PY_ROOT) or (name ~= "" and vim.fs.dirname(name)) or vim.fn.getcwd()
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
  for _, exe in ipairs({ "python3", "python" }) do
    if has(exe) then return vim.fn.exepath(exe) end
  end
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
      python = {},
    },
    -- 启动前把项目 venv 告诉 pyright，否则第三方包会报 "无法解析导入"
    before_init = function(_, config)
      config.settings.python.pythonPath = python_for(config.root_dir)
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
}
for name, cfg in pairs(servers) do
  local exe = find_exe(cfg.cmd[1])
  if exe then                   -- 没装的服务器直接跳过
    cfg.cmd[1] = exe
    vim.lsp.config(name, cfg)
    vim.lsp.enable(name)
  end
end

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

    -- 补全：该缓冲区关掉原生 'autocomplete'，改由 LSP 自动补全，避免两套同时弹出
    if supports("textDocument/completion") then
      local local_off = pcall(function() vim.bo[b].autocomplete = false end)
      vim.lsp.completion.enable(true, client.id, b, { autotrigger = local_off or not o.autocomplete })
    end

    map("n", "gd", vim.lsp.buf.definition, opts("Definition"))
    map("i", "<M-s>", vim.lsp.buf.signature_help, opts("Signature help"))
    if supports("textDocument/formatting") then
      map({ "n", "x" }, "<leader>cf", function() vim.lsp.buf.format({ bufnr = b }) end, opts("Format"))
    end

    -- 折叠：没有 treesitter 折叠时，用 LSP 的 foldingRange
    if supports("textDocument/foldingRange") and vim.api.nvim_get_current_buf() == b
      and vim.wo.foldmethod ~= "expr" then
      local wo = vim.wo[0][0]
      wo.foldmethod, wo.foldexpr = "expr", "v:lua.vim.lsp.foldexpr()"
    end

    -- 0.12 可选能力：内联提示 / 联动编辑（改 HTML 开标签时同步闭标签）/ CodeLens
    if USER.inlay_hints and supports("textDocument/inlayHint") then
      vim.lsp.inlay_hint.enable(true, { bufnr = b })
    end
    if supports("textDocument/linkedEditingRange") and vim.lsp.linked_editing_range then
      pcall(vim.lsp.linked_editing_range.enable, true, { client_id = client.id })
    end
    if supports("textDocument/codeLens") and vim.lsp.codelens.enable then
      pcall(vim.lsp.codelens.enable, true, { bufnr = b })
    end
  end,
})

----------------------------------------------------------------------
-- 10. LaTeX (优先交给 Overseer：启动/完成都有通知、错误进 quickfix；没有 Overseer 时在底部终端运行)
----------------------------------------------------------------------
-- 通用任务运行（LaTeX / Python 共用）
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
  if not has("latexmk") then
    return vim.notify("未找到 latexmk，请先安装 TeX Live / MiKTeX", L.ERROR)
  end
  local ok, err = pcall(vim.cmd, "silent update")
  if not ok then return vim.notify("保存失败: " .. tostring(err), L.ERROR) end
  if vim.fn.filereadable(file) == 0 then
    return vim.notify("当前文件还没保存到磁盘", L.ERROR)
  end
  local cmd = vim.list_extend(vim.list_extend({ "latexmk" }, args), { vim.fs.basename(file) })
  run_job({ name = title, cmd = cmd, cwd = vim.fs.dirname(file) })
end

-- -synctex=1：PDF ↔ 源码跳转；-file-line-error：错误格式为 file:line:，可被 quickfix 解析
local TEX = { USER.latex_engine, "-synctex=1", "-file-line-error", "-interaction=nonstopmode", "-halt-on-error" }
map("n", "<leader>tt", function() latexmk(TEX, "LaTeX 编译") end, { desc = "Compile" })
map("n", "<leader>tw", function()
  latexmk(vim.list_extend({ "-pvc", "-view=none" }, TEX), "LaTeX 持续编译")  -- <Space>oa 停止
end, { desc = "Continuous compile (-pvc)" })
map("n", "<leader>te", function() latexmk(vim.list_extend({ "-gg" }, TEX), "LaTeX 完全重建") end, { desc = "Full rebuild" })
map("n", "<leader>tc", function() latexmk({ "-c" }, "LaTeX 清理") end, { desc = "Clean aux (keep PDF)" })
map("n", "<leader>tv", function()
  local pdf = vim.fn.expand("%:p:r") .. ".pdf"
  if vim.fn.filereadable(pdf) == 0 then
    return vim.notify("找不到 PDF，请先编译 (<Space>tt)", L.WARN)
  end
  for _, v in ipairs(USER.pdf_viewers) do
    if has(v) and pcall(vim.system, { v, pdf }, { detach = true }) then
      return vim.notify("用 " .. v .. " 打开 " .. vim.fs.basename(pdf))
    end
  end
  local _, err = vim.ui.open(pdf)              -- 系统默认程序，macOS / Windows 也能用
  if err then vim.notify(err, L.ERROR) else vim.notify("用系统默认程序打开 PDF") end
end, { desc = "View PDF" })

----------------------------------------------------------------------
-- 11. Python（与 LaTeX 同样：优先交给 Overseer，错误进 quickfix；没有 Overseer 时在底部终端运行）
--     可选外部工具：ruff（lint/格式化）、项目环境里的 pytest / ipython；缺了只跳过对应功能
----------------------------------------------------------------------
-- 续行缩进用 1 个 shiftwidth（PEP 8 风格，内置默认是 2 个）
vim.g.python_indent = { open_paren = "shiftwidth()", continue = "shiftwidth()",
                        closed_paren_align_last_line = false }

-- traceback：每个 File 行一条，最后的异常行作为消息；pytest --tb=line 输出 file:line: msg
local PY_EFM     = [[%A  File "%f"\, line %l%.%#,%C %.%#,%Z%[%^ ]%\@=%m]]
local PYTEST_EFM = [[%f:%l: %m]]

local function term_run(cmd, cwd)   -- 需要交互（input() / pdb）时用真终端
  vim.cmd("botright 15new")
  vim.fn.jobstart(cmd, { term = true, cwd = cwd })
  vim.cmd.startinsert()
end

-- 检查 + 保存 + 收集上下文；失败返回 nil
local function py_ctx()
  if vim.bo.filetype ~= "python" then return vim.notify("当前不是 Python 文件", L.WARN) end
  local ok, err = pcall(vim.cmd, "silent update")
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

-- 运行 ---------------------------------------------------------------
map("n", "<leader>pr", function()
  local c = py_ctx(); if not c then return end
  run_job({ name = "Python " .. vim.fs.basename(c.file), cmd = { c.py, "-u", c.file },
            cwd = c.root, efm = PY_EFM })
end, { desc = "Run file" })

map("n", "<leader>pa", function()
  local c = py_ctx(); if not c then return end
  vim.ui.input({ prompt = "参数: ", default = vim.b.py_args or "" }, function(s)
    if not s then return end
    vim.b.py_args = s
    local cmd = table.concat(vim.tbl_map(vim.fn.shellescape, { c.py, "-u", c.file }), " ") .. " " .. s
    run_job({ name = "Python " .. vim.fs.basename(c.file) .. " " .. s, cmd = cmd, cwd = c.root, efm = PY_EFM })
  end)
end, { desc = "Run with args" })

map("n", "<leader>pw", function()   -- 项目内任意文件保存都会重跑；<Space>oa 停止
  local c = py_ctx(); if not c then return end
  run_job({ name = "Python 监视 " .. vim.fs.basename(c.file), cmd = { c.py, "-u", c.file },
            cwd = c.root, efm = PY_EFM, watch = c.root })
end, { desc = "Rerun on save" })

map("n", "<leader>pd", function()   -- 配合 <Space>pb 插入的 breakpoint() 进 pdb
  local c = py_ctx(); if not c then return end
  term_run({ c.py, c.file }, c.root)
end, { desc = "Run in terminal (interactive/pdb)" })

map("n", "<leader>pb", function()
  if vim.bo.filetype ~= "python" or not editable() then return end
  local row = vim.api.nvim_win_get_cursor(0)[1]
  local line = vim.api.nvim_get_current_line()
  if line:match("^%s*breakpoint%(%)%s*$") then
    vim.api.nvim_buf_set_lines(0, row - 1, row, false, {})
  else
    vim.api.nvim_buf_set_lines(0, row - 1, row - 1, false, { line:match("^%s*") .. "breakpoint()" })
  end
end, { desc = "Toggle breakpoint()" })

-- 测试 (pytest) ------------------------------------------------------
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
  local cmd = { c.py, "-m", "pytest", "-q", "--tb=line" }
  if target then table.insert(cmd, target) end
  run_job({ name = title, cmd = cmd, cwd = c.root, efm = PYTEST_EFM })
end

map("n", "<leader>pt", function()
  local c = py_ctx(); if not c then return end
  local id = nearest_test(c.file)
  if not id then return vim.notify("光标上方没有 test_ 函数", L.WARN) end
  pytest(c, id, "pytest " .. id:match("::(.*)$"))
end, { desc = "Test nearest" })
map("n", "<leader>pf", function()
  local c = py_ctx(); if c then pytest(c, c.file, "pytest " .. vim.fs.basename(c.file)) end
end, { desc = "Test file" })
map("n", "<leader>pT", function()
  local c = py_ctx(); if c then pytest(c, nil, "pytest 全部") end
end, { desc = "Test all" })

-- ruff 代码操作 / 保存时格式化 ----------------------------------------
local function ruff_action(kind)
  if #vim.lsp.get_clients({ bufnr = 0, name = "ruff" }) == 0 then
    return vim.notify("ruff 未运行（需要安装 ruff）", L.WARN)
  end
  vim.lsp.buf.code_action({ context = { only = { kind }, diagnostics = {} }, apply = true })
end
map("n", "<leader>pi", function() ruff_action("source.organizeImports.ruff") end, { desc = "Organize imports" })
map("n", "<leader>px", function() ruff_action("source.fixAll.ruff") end,         { desc = "Ruff fix all" })

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

au("FileType", {
  group = group, pattern = "python",
  callback = function() vim.opt_local.colorcolumn = tostring(USER.py_line_length + 1) end,
})

-- 选择解释器 ---------------------------------------------------------
-- 列出：$VIRTUAL_ENV、项目内各 venv、当前 conda 环境、conda base 及 envs/ 下所有环境、PATH
map("n", "<leader>pv", function()
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
  for _, exe in ipairs({ "python3", "python" }) do
    if has(exe) then add(vim.fn.exepath(exe), "PATH") end
  end
  table.insert(items, { label = "手动输入路径…" })

  local function apply(p)
    if vim.fn.executable(p) == 0 then return vim.notify("不可执行: " .. p, L.ERROR) end
    py_chosen[root] = p
    for _, cl in ipairs(vim.lsp.get_clients({ bufnr = 0, name = "basedpyright" })) do
      cl.settings = vim.tbl_deep_extend("force", cl.settings or {}, { python = { pythonPath = p } })
      cl:notify("workspace/didChangeConfiguration", { settings = cl.settings })
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
end, { desc = "Select interpreter" })

-- REPL ---------------------------------------------------------------
-- 有 ipython 用 ipython（括号粘贴，多行块最稳）；否则普通 python，多行代码经临时文件 exec
local repl = {}

local function repl_win() return repl.buf and vim.fn.bufwinid(repl.buf) or -1 end

local function repl_open()
  if repl.chan and repl.buf and vim.api.nvim_buf_is_valid(repl.buf) then
    if repl_win() == -1 then
      local cur = vim.api.nvim_get_current_win()
      vim.cmd("botright 15split")
      vim.api.nvim_win_set_buf(0, repl.buf)
      vim.api.nvim_set_current_win(cur)
    end
    return true
  end
  local root = py_root(0)
  local py = python_for(root)
  if not py then return vim.notify("找不到 Python 解释器", L.ERROR) end
  local ipy = vim.fs.joinpath(vim.fs.dirname(py), IS_WIN and "ipython.exe" or "ipython")
  repl.ipython = vim.uv.fs_stat(ipy) ~= nil
  local cmd = repl.ipython and { ipy, "--no-autoindent" } or { py, "-q" }
  local cur = vim.api.nvim_get_current_win()
  vim.cmd("botright 15new")
  repl.buf = vim.api.nvim_get_current_buf()
  repl.chan = vim.fn.jobstart(cmd, { term = true, cwd = root,
                                     on_exit = function() repl.chan, repl.buf = nil, nil end })
  vim.api.nvim_set_current_win(cur)
  return true
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
  elseif repl.ipython then
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

map("n", "<leader>pp", function()
  local win = repl_win()
  if win ~= -1 then vim.api.nvim_win_close(win, false) else repl_open() end
end, { desc = "Toggle REPL" })
map("n", "<leader>ps", function() repl_send({ vim.api.nvim_get_current_line() }) end, { desc = "Send line" })
map("x", "<leader>ps", function()
  local lines = vim.fn.getregion(vim.fn.getpos("v"), vim.fn.getpos("."), { type = vim.fn.mode() })
  vim.api.nvim_feedkeys(vim.keycode("<Esc>"), "nx", false)
  repl_send(lines)
end, { desc = "Send selection" })

----------------------------------------------------------------------
-- 12. Neovide
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
  local size = USER.font_size
  local function font(n) size = n; o.guifont = ("%s:h%d"):format(USER.font, n) end
  map("n", "<C-=>", function() font(size + 1) end,               { desc = "Font +" })
  map("n", "<C-->", function() font(math.max(6, size - 1)) end,  { desc = "Font -" })
  map("n", "<C-0>", function() font(USER.font_size) end,         { desc = "Font reset" })
end

----------------------------------------------------------------------
-- 13. 缺失插件汇总提示（只提示一次）
----------------------------------------------------------------------
if #missing > 0 then
  vim.schedule(function()
    local hints = { "修复后重启 nvim 会自动安装" }
    if not has("git") then table.insert(hints, 1, "未找到 git：vim.pack 需要 git 才能安装插件") end
    if not MIRROR then table.insert(hints, "国内网络可设置镜像: export NVIM_PACK_MIRROR=https://ghfast.top/") end
    vim.notify(("以下插件未加载，相关功能已跳过，编辑器可正常使用:\n  %s\n%s")
      :format(table.concat(missing, ", "), table.concat(hints, "\n")), L.WARN)
  end)
end
