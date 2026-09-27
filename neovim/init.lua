-- ~/.config/nvim/init.lua  (仅支持 Neovim 0.12+)
--
-- ╔══════════════════════════════ PLUGINS ══════════════════════════════════
-- ║ 插件共 3 个: mini.nvim / multicursor.nvim / overseer.nvim
-- ║ 首次启动时由内置 vim.pack 自动安装（需要 git），不用手动 git clone
-- ║ 版本记录在 ~/.config/nvim/nvim-pack-lock.json（分享配置时一起提交）
-- ║ 任一插件缺失时自动跳过相关功能，编辑器照常可用，启动后汇总提示一次
-- ║
-- ║ 国内网络：在 shell 配置里设置镜像（第三方服务，默认不用；末尾的 / 可省略）
-- ║   export NVIM_PACK_MIRROR=https://ghfast.top/
-- ║ 预装（服务器 / CI）：nvim --headless +qa
-- ║
-- ║ 推荐外部工具：ripgrep / fd（更快的查找）、latexmk（LaTeX）、各语言 LSP（见第 9 节）
-- ║ :PackUpdate [名字…] 检查更新（:write 确认 / :quit 放弃）  :PackClean 删除不再使用的插件
-- ╚═════════════════════════════════════════════════════════════════════════
--
-- ╔══════════════════════════════ CHEATSHEET ═════════════════════════════
-- ║ <Space> 为 Leader。按下 <Space> / g / z / [ / ] 后停顿，会弹出按键提示
-- ╟─ 文件 / 查找 ─────────────────────────────────────────────────────────
-- ║ <C-s> 保存   <Space>w 写入   <Space>q 退出   -  文件浏览(netrw)
-- ║ <Space>ff 文件   fg 全文搜索   fb 缓冲区   fo 最近文件   fh 帮助
-- ║ <Space>fl 当前文件行   fd 诊断   fr 恢复上次查找
-- ╟─ 包围 (vim-surround 风格, mini.surround) ─────────────────────────────
-- ║ ysiw"  给单词加 "        yss)  整行加括号       可视模式选中后 S(  加括号
-- ║ ds(    删除包围 ()       cs"'  把 " 换成 '      ysiwt / ysiwf  标签/函数
-- ║ %  跳到配对括号          vi( / va"  选中括号内 / 连引号选中 (内置)
-- ║ 文本对象(mini.ai): ( [ { " ' ` 之外还有 f=函数调用 a=参数 t=标签 q=引号
-- ╟─ 多光标 (multicursor.nvim) ───────────────────────────────────────────
-- ║ C / <M-C>       在下方 / 上方加光标 (也可用 <C-Down> / <C-Up>)
-- ║ <C-n> / <M-n>   加下一个相同词 / 跳过      <C-p> / <M-p> 向上找
-- ║ <Space>A        选中全部相同词             gaip  段落每行一个光标
-- ║ 可视 s / <M-s>  选区内按正则选中 / 按正则拆分  (最常用: vip → s → 正则)
-- ║ 可视 I / A      每行行首插入 / 行尾追加    <C-q> 在此处放置/暂停光标
-- ║ ── 以下仅在有多光标时生效 ──
-- ║ ( )  切换主光标   <M-,> 删除主光标   &  对齐各列   <M-(> <M-)> 轮换选区内容
-- ║ ,  或 <Esc>  回到单光标           <Space>gv  找回刚清除的光标
-- ╟─ 任务 (Overseer) / LaTeX ──────────────────────────────────────────────
-- ║ <Space>or 运行任务(make/npm/cargo/tasks.json…)   oo 任务面板   ol 重跑最近任务
-- ║ <Space>oa 对任务执行操作(重启/停止/打开输出)       os 把 shell 命令作为任务运行
-- ║ <Space>tt 编译   te 完全重建   tc 清理辅助文件(保留 PDF)   tv 打开 PDF
-- ║ (所有任务启动、结束时都会弹出通知；没有 Overseer 时在底部终端里编译)
-- ╟─ LSP / Git ─────────────────────────────────────────────────────────────
-- ║ gd 跳到定义   K 悬停文档   grr 引用   gri 实现   gO 符号列表
-- ║ <Space>rn 重命名   <Space>ca 代码操作   [d ]d 上/下一个诊断
-- ║ ]h [h 下/上一个修改块   ghgh 暂存光标处修改块   gHgh 撤销 (可视模式 gh / gH)
-- ║ <Space>go 显示差异   <Space>gs 光标处的提交信息
-- ╟─ 编辑 / 其他 ───────────────────────────────────────────────────────────
-- ║ gc / gcc 注释(内置)   <M-j>/<M-k> 上下移动行   <C-h/j/k/l> 切换窗口
-- ║ \  替换光标下单词   <Esc> 清除搜索高亮   插入模式 <M-d> 插入时间
-- ║ F9 深/浅色   F10 拼写检查   F11 分隔线   F12 文件头
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
  clipboard    = "unnamedplus",              -- 与系统剪贴板同步；设为 "" 则不同步
  auto_cd      = true,                       -- 打开文件时自动切换到项目根目录
  root_markers = { ".git", "Makefile", "justfile", "package.json", "pyproject.toml",
                   "Cargo.toml", "pubspec.yaml", ".vscode" },  -- 越靠前优先级越高
  deco_width   = 80,                         -- F11 / F12 注释装饰的宽度
  latex_engine = "-xelatex",                 -- latexmk 引擎: -xelatex / -lualatex / -pdf
  pdf_viewers  = { "okular", "evince", "zathura" },  -- 按顺序尝试，都没有就用系统默认程序
  bigfile_mb   = 5,                          -- 超过此大小的文件关闭高亮 / diff / undo 文件
  -- LSP 服务器列表见第 9 节
}

vim.g.mapleader      = " "
vim.g.maplocalleader = " "

local map   = vim.keymap.set
local L     = vim.log.levels
local au    = vim.api.nvim_create_autocmd
local group = vim.api.nvim_create_augroup("UserConfig", { clear = true })
local function has(exe) return vim.fn.executable(exe) == 1 end

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

vim.api.nvim_create_user_command("PackUpdate", function(a)
  vim.notify("正在检查插件更新" .. (MIRROR and ("（经镜像 " .. MIRROR .. "）") or "") .. " ...")
  local ok, err = with_git_env(function() vim.pack.update(#a.fargs > 0 and a.fargs or nil) end)
  if not ok then vim.notify("更新失败: " .. tostring(err), L.ERROR) end
  -- 会打开确认页：:write 应用，:quit 放弃；应用后 :restart 生效
end, { nargs = "*", desc = "Update plugins" })

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
local o = vim.o

o.number       = true
o.cursorline, o.cursorcolumn = true, true
o.signcolumn   = "yes"
o.scrolloff    = 6
o.showmatch, o.matchtime = true, 2
o.colorcolumn  = "+1"
o.list         = true
o.listchars    = "tab:│ ,trail:·,extends:#,nbsp:."
o.winborder    = "rounded"

o.wrap, o.linebreak = true, true
o.whichwrap    = "b,s,<,>,[,],h,l"

o.expandtab = true
o.shiftwidth, o.tabstop, o.softtabstop = USER.indent, USER.indent, USER.indent
o.smartindent, o.shiftround = true, true

o.ignorecase, o.smartcase = true, true

o.undofile      = true
o.confirm       = true
o.fileencodings = "ucs-bom,utf-8,gbk,big5,latin1"   -- 先认 BOM；latin1 兜底，保证总能打开

o.foldmethod, o.foldlevel = "indent", 99

o.timeoutlen   = 400
o.switchbuf    = "useopen,usetab,newtab"
o.splitright, o.splitbelow = true, true
o.completeopt  = "menu,menuone,noselect,popup,fuzzy"
o.path         = o.path .. ",**"
o.wildignore   = "*/node_modules/*,*/.git/*,*/target/*,*/dist/*,*.o,*.pyc"
o.wildoptions  = "pum,fuzzy"
o.wildmode     = "longest:full,full"

o.formatlistpat = [[^\s*\(\d\+\|[-*]\)\+[\]:.)}\t ]\s*]]
vim.opt.formatoptions:append("n")

-- 剪贴板延后设置：检测剪贴板工具可能较慢（SSH / WSL），不拖慢启动
vim.schedule(function() o.clipboard = USER.clipboard end)

vim.g.netrw_banner, vim.g.netrw_liststyle = 0, 3
vim.g.netrw_browse_split, vim.g.netrw_winsize = 0, 25

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
-- 通知用浮窗显示，不会被命令行消息覆盖；历史记录：:lua MiniNotify.show_history()
use("mini.notify", function(m)
  m.setup()
  vim.notify = m.make_notify()
end)

use("mini.starter",    function(m) m.setup() end)
use("mini.pairs",      function(m) m.setup() end)
use("mini.ai",         function(m) m.setup({ n_lines = 500 }) end)
use("mini.statusline", function(m) m.setup({ use_icons = false }) end)

use("mini.git", function(m)
  m.setup()
  map({ "n", "x" }, "<leader>gs", function() m.show_at_cursor() end, { desc = "Git at cursor" })
end)

use("mini.diff", function(m)
  m.setup({ view = { style = "sign" } })
  map("n", "<leader>go", function() m.toggle_overlay() end, { desc = "Diff overlay" })
end)

-- 查找 + 接管 vim.ui.select（Overseer 的选择框也用它）
-- 有 rg/fd 用它们；没有时在 git 仓库里用 git，否则用纯 Lua 实现（慢，但哪里都能用）
local function pick_tool(fast)
  if fast then return nil end
  return (has("git") and vim.fs.root(vim.fn.getcwd(), ".git")) and "git" or "fallback"
end

local pick = use("mini.pick", function(m)
  m.setup()
  vim.ui.select = m.ui_select
  local b = m.builtin
  map("n", "<leader>ff", function() b.files({ tool = pick_tool(has("rg") or has("fd")) }) end, { desc = "Files" })
  map("n", "<leader>fg", function()
    local t = pick_tool(has("rg"))
    if t == "fallback" then b.grep({ tool = t }) else b.grep_live({ tool = t }) end  -- 实时搜索需要 rg/git
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
  clue.setup({
    triggers = {
      { mode = "n", keys = "<Leader>" }, { mode = "x", keys = "<Leader>" },
      { mode = "n", keys = "g" },        { mode = "x", keys = "g" },
      { mode = "n", keys = "z" },        { mode = "x", keys = "z" },
      { mode = "n", keys = "[" },        { mode = "n", keys = "]" },
      { mode = "n", keys = "<C-w>" },
    },
    clues = {
      clue.gen_clues.g(), clue.gen_clues.z(), clue.gen_clues.windows(),
      { mode = "n", keys = "<Leader>f", desc = "+Find" },
      { mode = "n", keys = "<Leader>o", desc = "+Overseer" },
      { mode = "n", keys = "<Leader>t", desc = "+LaTeX" },
      { mode = "n", keys = "<Leader>g", desc = "+Git" },
    },
    window = { delay = 300 },
  })
end)

----------------------------------------------------------------------
-- 4. 多光标
----------------------------------------------------------------------
use("multicursor-nvim", function(mc)
  mc.setup()

  map({ "n", "x" }, "C",        function() mc.lineAddCursor(1)  end, { desc = "Cursor below" })
  map({ "n", "x" }, "<M-C>",    function() mc.lineAddCursor(-1) end, { desc = "Cursor above" })
  map({ "n", "x" }, "<C-Down>", function() mc.lineAddCursor(1)  end, { desc = "Cursor below" })
  map({ "n", "x" }, "<C-Up>",   function() mc.lineAddCursor(-1) end, { desc = "Cursor above" })

  map({ "n", "x" }, "<C-n>", function() mc.matchAddCursor(1)   end, { desc = "Add next match" })
  map({ "n", "x" }, "<M-n>", function() mc.matchSkipCursor(1)  end, { desc = "Skip next match" })
  map({ "n", "x" }, "<C-p>", function() mc.matchAddCursor(-1)  end, { desc = "Add prev match" })
  map({ "n", "x" }, "<M-p>", function() mc.matchSkipCursor(-1) end, { desc = "Skip prev match" })
  map({ "n", "x" }, "<leader>A", mc.matchAllAddCursors,             { desc = "Add all matches" })

  map("x", "s",     mc.matchCursors, { desc = "Select regex in selection" })
  map("x", "<M-s>", mc.splitCursors, { desc = "Split selection by regex" })   -- 可视 S 留给包围
  map("x", "I", mc.insertVisual, { desc = "Insert each line" })
  map("x", "A", mc.appendVisual, { desc = "Append each line" })
  map({ "n", "x" }, "ga", mc.addCursorOperator, { desc = "Cursors over motion" })

  map({ "n", "x" }, "<C-q>", mc.toggleCursor,   { desc = "Toggle cursor" })
  map("n", "<leader>gv",     mc.restoreCursors, { desc = "Restore cursors" })

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
      -- 在官方默认组件前面加上 on_start_notify；完成时的通知仍由 on_complete_notify 负责
      default = {
        "on_start_notify",
        "on_exit_set_status",
        "on_complete_notify",
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
map({ "n", "i", "x", "s" }, "<C-g>", "<Esc>")
map("c", "<C-g>", "<C-c>")
map({ "n", "x" }, "<C-z>", ":")
map("i", "<C-z>", "<C-o>:")
map("n", "<C-F4>", "<C-w>c")
map("i", "<C-F4>", "<Esc><C-w>c")
map("c", "<C-F4>", "<C-c><C-w>c")

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
map({ "n", "x", "i" }, "<C-s>", function() save("update") end, { desc = "Save" })

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
map("n", "<leader>cd", "<cmd>cd %:p:h<cr><cmd>pwd<cr>", { desc = "cd to file dir" })
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

-- Tab：片段占位符跳转 > 菜单下一项 > 行首/空白后缩进 > LSP 或关键字补全
map("i", "<Tab>", function()
  if vim.snippet.active({ direction = 1 }) then return "<Cmd>lua vim.snippet.jump(1)<CR>" end
  if vim.fn.pumvisible() == 1 then return "<C-n>" end
  local col = vim.fn.col(".") - 1
  if col == 0 or vim.fn.getline("."):sub(col, col):match("%s") then return "<Tab>" end
  return vim.bo.omnifunc ~= "" and "<C-x><C-o>" or "<C-n>"
end, { expr = true })
map("i", "<S-Tab>", function()
  if vim.snippet.active({ direction = -1 }) then return "<Cmd>lua vim.snippet.jump(-1)<CR>" end
  return vim.fn.pumvisible() == 1 and "<C-p>" or "<S-Tab>"
end, { expr = true })

----------------------------------------------------------------------
-- 7. 注释装饰 (F11 分隔线 / F12 文件头)
----------------------------------------------------------------------
local DECO = { width = USER.deco_width, rule = "-", head = "=" }
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

-- 自动切换到项目根目录 (找不到就用文件所在目录)；Overseer / Pick 都依赖 cwd
if USER.auto_cd then
  local home = vim.fs.normalize(vim.uv.os_homedir() or "")
  au("BufEnter", {
    group = group,
    callback = function(args)
      if vim.bo[args.buf].buftype ~= "" then return end
      local name = vim.api.nvim_buf_get_name(args.buf)
      if name == "" or name:find("://", 1, true) then return end   -- 插件的虚拟缓冲区
      local root = vim.fs.root(args.buf, USER.root_markers)
      if not root or root == home then root = vim.fs.dirname(name) end  -- 家目录是 dotfiles 仓库时不切到 ~
      if root and root ~= vim.fs.normalize(vim.fn.getcwd()) and vim.fn.isdirectory(root) == 1 then
        pcall(vim.fn.chdir, root)
      end
    end,
  })
end

-- 保存时去掉行尾空白 (markdown / diff / 二进制 / 大文件除外)
local NO_TRIM = { markdown = true, diff = true }
au("BufWritePre", {
  group = group,
  callback = function(args)
    local bo = vim.bo[args.buf]
    if bo.binary or not bo.modifiable or NO_TRIM[bo.filetype] or vim.b[args.buf].bigfile then return end
    vim.api.nvim_buf_call(args.buf, function()
      local view = vim.fn.winsaveview()
      vim.cmd([[keeppatterns silent! %s/\s\+$//e]])
      vim.fn.winrestview(view)
    end)
  end,
})

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
      vim.notify(("大文件 (>%dMB)：已关闭高亮 / diff / undo 文件"):format(USER.bigfile_mb))
    end
  end,
})

-- 有 treesitter 解析器就用它高亮，没有就用传统 syntax；大文件两者都关（含 ftplugin 自启的 treesitter）
au("FileType", {
  group = group,
  callback = function(args)
    local buf = args.buf
    if vim.b[buf].bigfile then
      vim.schedule(function()
        if not vim.api.nvim_buf_is_valid(buf) then return end
        pcall(vim.treesitter.stop, buf)
        vim.bo[buf].syntax = "OFF"
      end)
      return
    end
    pcall(vim.treesitter.start, buf)
  end,
})

----------------------------------------------------------------------
-- 9. LSP (vim.lsp.config / enable)；grr gri grn gra gO K 为内置默认键
----------------------------------------------------------------------
vim.diagnostic.config({ virtual_text = true, severity_sort = true })

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
    if client and client:supports_method("textDocument/completion") then
      vim.lsp.completion.enable(true, client.id, b, { autotrigger = true })
    end
    local opts = { buffer = b }
    map("n", "gd", vim.lsp.buf.definition, opts)
    map("n", "<leader>rn", vim.lsp.buf.rename, opts)
    map("n", "<leader>ca", vim.lsp.buf.code_action, opts)
    map("n", "[d", function() vim.diagnostic.jump({ count = -1, float = true }) end, opts)
    map("n", "]d", function() vim.diagnostic.jump({ count =  1, float = true }) end, opts)
  end,
})

----------------------------------------------------------------------
-- 10. LaTeX (优先交给 Overseer：启动/完成都有通知；没有 Overseer 时在底部终端运行)
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
    overseer.new_task({ name = title, cmd = cmd, cwd = dir }):start()
  else
    vim.cmd("botright 12new")
    vim.fn.jobstart(cmd, { term = true, cwd = dir })
  end
end

local TEX = { USER.latex_engine, "-interaction=nonstopmode", "-halt-on-error" }
map("n", "<leader>tt", function() latexmk(TEX, "LaTeX 编译") end, { desc = "Compile" })
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
  map("n", "<C-=>", function() font(size + 1) end)
  map("n", "<C-->", function() font(math.max(6, size - 1)) end)
  map("n", "<C-0>", function() font(USER.font_size) end)
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
