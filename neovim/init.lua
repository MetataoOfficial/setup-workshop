-- ~/.config/nvim/init.lua  (仅支持 Neovim 0.12+)      完整说明见同目录 README.md
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
-- ╟─ 多光标 ───────────────────────────────────────────────────────────────
-- ║ <C-Down>/<C-Up> 或 <Space>mj/mk 上下加光标   <C-n>/<C-p> 加下/上一个相同词
-- ║ <M-n>/<M-p> 跳过   <Space>ma 全部相同词   gaip 段落每行   <C-q> 放置/暂停光标
-- ║ 可视: s 按正则选中  <M-s> 按正则拆分  I/A 每行插入/追加
-- ║ 有多光标时: ( ) 切换主光标  <M-,> 删除  & 对齐  <M-(>/<M-)> 轮换  , 或 <Esc> 退出
-- ║ <Space>mv 找回刚清除的光标
-- ╟─ 任务 / LaTeX ─────────────────────────────────────────────────────────
-- ║ <Space>or 运行  oo 面板  ol 重跑最近  oa 操作  os shell 命令
-- ║ <Space>tt 编译  tw 持续编译  te 完全重建  tc 清理  tv 打开 PDF
-- ╟─ LSP / 诊断 / Git（大多为 0.12 内置键） ─────────────────────────────
-- ║ gd 定义  K 文档  grn 重命名  gra 代码操作  grr 引用  gri 实现  grt 类型定义  gO 符号
-- ║ <Space>cf 格式化   插入模式 <M-s> 签名帮助   [d ]d 诊断(自动弹窗)  <C-w>d 诊断浮窗
-- ║ ]h [h 修改块  ghgh 暂存  gHgh 撤销  <Space>go 差异  <Space>gs 提交信息
-- ╟─ 开关 / 其他 ──────────────────────────────────────────────────────────
-- ║ <Space>uu 撤销树  uh 内联提示  uw 保存时去行尾空白   F9 深浅色  F10 拼写
-- ║ gc/gcc 注释  <M-j>/<M-k> 移动行  <C-h/j/k/l> 切窗口  \ 替换光标词
-- ║ 终端 <Esc><Esc> 回普通模式   插入 <M-d> 时间   F11 分隔线  F12 文件头
-- ╚═════════════════════════════════════════════════════════════════════════

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
  -- LSP 服务器列表见第 9 节
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
o.scrolloff    = 6
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
o.wildignore  = "*/node_modules/*,*/.git/*,*/target/*,*/dist/*,*.o,*.pyc"
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
      { mode = "n", keys = "<Leader>m", desc = "+Multicursor" },
      { mode = "x", keys = "<Leader>m", desc = "+Multicursor" },
      { mode = "n", keys = "<Leader>o", desc = "+Overseer" },
      { mode = "n", keys = "<Leader>t", desc = "+LaTeX" },
      { mode = "n", keys = "<Leader>u", desc = "+Toggle / UI" },
    },
    window = { delay = 300 },
  })
end)

----------------------------------------------------------------------
-- 4. 多光标 (C 保留给内置的 c$)
----------------------------------------------------------------------
use("multicursor-nvim", function(mc)
  mc.setup()

  map({ "n", "x" }, "<C-Down>",   function() mc.lineAddCursor(1)  end, { desc = "Cursor below" })
  map({ "n", "x" }, "<C-Up>",     function() mc.lineAddCursor(-1) end, { desc = "Cursor above" })
  map({ "n", "x" }, "<leader>mj", function() mc.lineAddCursor(1)  end, { desc = "Cursor below" })
  map({ "n", "x" }, "<leader>mk", function() mc.lineAddCursor(-1) end, { desc = "Cursor above" })

  map({ "n", "x" }, "<C-n>", function() mc.matchAddCursor(1)   end, { desc = "Add next match" })
  map({ "n", "x" }, "<M-n>", function() mc.matchSkipCursor(1)  end, { desc = "Skip next match" })
  map({ "n", "x" }, "<C-p>", function() mc.matchAddCursor(-1)  end, { desc = "Add prev match" })
  map({ "n", "x" }, "<M-p>", function() mc.matchSkipCursor(-1) end, { desc = "Skip prev match" })
  map({ "n", "x" }, "<leader>ma", mc.matchAllAddCursors,            { desc = "Add all matches" })
  map("n",          "<leader>mv", mc.restoreCursors,                { desc = "Restore cursors" })

  map("x", "s",     mc.matchCursors, { desc = "Select regex in selection" })
  map("x", "<M-s>", mc.splitCursors, { desc = "Split selection by regex" })   -- 可视 S 留给包围
  map("x", "I", mc.insertVisual, { desc = "Insert each line" })
  map("x", "A", mc.appendVisual, { desc = "Append each line" })
  map({ "n", "x" }, "ga", mc.addCursorOperator, { desc = "Cursors over motion" })
  map({ "n", "x" }, "<C-q>", mc.toggleCursor,   { desc = "Toggle cursor" })

  map("n", "<C-LeftMouse>",   mc.handleMouse)
  map("n", "<C-LeftDrag>",    mc.handleMouseDrag)
  map("n", "<C-LeftRelease>", mc.handleMouseRelease)

  -- 仅在存在多光标时生效
  mc.addKeymapLayer(function(set)
    set({ "n", "x" }, ")", mc.nextCursor)
    set({ "n", "x" }, "(", mc.prevCursor)
    set({ "n", "x" }, "<M-,>", mc.deleteCursor)
    set("n", ",", mc.clearCursors)
    set("n", "&", mc.alignCursors)
    set("x", "<M-)>", function() mc.transposeCursors(1)  end)
    set("x", "<M-(>", function() mc.transposeCursors(-1) end)
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
-- 自定义组件：任务一启动就通知 (OverseerRun / OverseerShell / 重跑 / LaTeX 都会触发)
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

local servers = {
  basedpyright = {
    cmd = { "basedpyright-langserver", "--stdio" }, filetypes = { "python" },
    root_markers = { "pyproject.toml", "setup.py", "setup.cfg", "requirements.txt", ".git" },
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
  if has(cfg.cmd[1]) then       -- 没装的服务器直接跳过
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
  local dir = vim.fs.dirname(file)
  local cmd = vim.list_extend(vim.list_extend({ "latexmk" }, args), { vim.fs.basename(file) })
  if overseer then
    overseer.new_task({
      name = title, cmd = cmd, cwd = dir,
      components = { { "on_output_quickfix", open_on_exit = "failure", items_only = true }, "default" },
    }):start()
  else
    vim.cmd("botright 12new")
    vim.fn.jobstart(cmd, { term = true, cwd = dir })
  end
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
-- 11. Neovide
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
-- 12. 缺失插件汇总提示（只提示一次）
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
