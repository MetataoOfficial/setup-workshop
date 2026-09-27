-- ~/.config/nvim/init.lua  (Neovim 0.12+)
--
-- ╔══════════════════════════════ PLUGINS ══════════════════════════════════
-- ║ 插件共 3 个: mini.nvim / multicursor.nvim / overseer.nvim
-- ║ 目录: ~/.local/share/nvim/site/pack/plugins/start/
-- ║
-- ║ mkdir -p ~/.local/share/nvim/site/pack/plugins/start
-- ║ cd ~/.local/share/nvim/site/pack/plugins/start
-- ║
-- ║ # 清理可能下载失败留下的残破目录
-- ║ rm -rf mini.nvim multicursor.nvim overseer.nvim
-- ║
-- ║ # 使用加速镜像下载这 3 个插件（如无需镜像可去掉前缀 ghfast.top/）
-- ║ git clone --depth 1 https://ghfast.top/https://github.com/echasnovski/mini.nvim mini.nvim
-- ║ git clone --depth 1 https://ghfast.top/https://github.com/jake-stewart/multicursor.nvim multicursor.nvim
-- ║ git clone --depth 1 https://ghfast.top/https://github.com/stevearc/overseer.nvim overseer.nvim
-- ╚═════════════════════════════════════════════════════════════════════════
--
-- ╔══════════════════════════════ CHEATSHEET ═════════════════════════════
-- ║ <Space> 为 Leader。按下 <Space> / g / m / z / [ / ] 后停顿，会弹出按键提示
-- ╟─ 文件 / 查找 ─────────────────────────────────────────────────────────
-- ║ <C-s> 保存   <Space>w 写入   <Space>q 退出   -  文件浏览(netrw)
-- ║ <Space>ff 文件   fg 全文搜索   fb 缓冲区   fo 最近文件   fh 帮助
-- ║ <Space>fl 当前文件行   fd 诊断   fr 恢复上次查找
-- ╟─ 包围 (Helix 风格, mini.surround) ────────────────────────────────────
-- ║ msiw"  给单词加 "        可视模式选中后 ms(  加括号 (不加空格)
-- ║ md(    删除包围 ()       mr"'  把 " 换成 '     msiwt / msiwf  标签/函数
-- ║ mm 跳到配对括号         mi( / ma"  选中括号内 / 连引号选中
-- ║ 文本对象(mini.ai): ( [ { " ' ` 之外还有 f=函数调用 a=参数 t=标签 q=引号
-- ╟─ 多光标 (Helix 风格, multicursor.nvim) ────────────────────────────────
-- ║ C / <M-C>       在下方 / 上方加光标 (也可用 <C-Down> / <C-Up>)
-- ║ <C-n> / <M-n>   加下一个相同词 / 跳过      <C-p> / <M-p> 向上找
-- ║ <Space>A        选中全部相同词             gaip  段落每行一个光标
-- ║ 可视 s / S      选区内按正则选中 / 按正则拆分  (最常用: vip → s → 正则)
-- ║ 可视 I / A      每行行首插入 / 行尾追加    <C-q> 在此处放置/暂停光标
-- ║ ── 以下仅在有多光标时生效 ──
-- ║ ( )  切换主光标   <M-,> 删除主光标   &  对齐各列   <M-(> <M-)> 轮换选区内容
-- ║ ,  或 <Esc>  回到单光标           <Space>gv  找回刚清除的光标
-- ╟─ 任务 (Overseer) / LaTeX ──────────────────────────────────────────────
-- ║ <Space>or 运行任务(make/npm/cargo/tasks.json…)   oo 任务面板   ol 重跑最近任务
-- ║ <Space>oa 对任务执行操作(重启/停止/打开输出)       os 把 shell 命令作为任务运行
-- ║ <Space>tt 编译   te 完全重建   tc 清理辅助文件   tv 打开 PDF
-- ╟─ LSP / Git ─────────────────────────────────────────────────────────────
-- ║ gd 跳到定义   K 悬停文档   grr 引用   gri 实现   gO 符号列表
-- ║ <Space>rn 重命名   <Space>ca 代码操作   [d ]d 上/下一个诊断
-- ║ ]h [h 下/上一个修改块  gh 暂存修改块  gH 撤销修改块  <Space>go 显示差异  gs 提交信息
-- ╟─ 编辑 / 其他 ───────────────────────────────────────────────────────────
-- ║ gc / gcc 注释(内置)   <M-j>/<M-k> 上下移动行   <C-h/j/k/l> 切换窗口
-- ║ \  替换光标下单词   <Esc> 清除搜索高亮   插入模式 <C-d> 插入时间
-- ║ F9 深/浅色   F10 拼写检查   F11 分隔线   F12 文件头
-- ║ :PluginUpdate 更新插件   :PluginClean 删除不在列表中的插件
-- ╚═════════════════════════════════════════════════════════════════════════

vim.g.mapleader      = " "
vim.g.maplocalleader = " "
local map = vim.keymap.set

----------------------------------------------------------------------
-- 0. 插件引导 (可选国内镜像；本地记录的始终是真实 GitHub 地址)
----------------------------------------------------------------------
local USE_MIRROR = true                    -- 已有全局代理就设为 false
local MIRROR     = "https://ghfast.top/"

local plugins = {
  { name = "mini.nvim",        src = "https://github.com/nvim-mini/mini.nvim" },
  { name = "multicursor.nvim", src = "https://github.com/jake-stewart/multicursor.nvim" },
  { name = "overseer.nvim",    src = "https://github.com/stevearc/overseer.nvim" },
}

local pack_dir = vim.fn.stdpath("data") .. "/site/pack/plugins/start/"
vim.fn.mkdir(pack_dir, "p")

-- 组装 git 命令：网速低于 1KB/s 持续 20 秒就自动放弃；开启镜像时临时替换地址
local function git(args)
  local cmd = { "git", "-c", "http.lowSpeedLimit=1000", "-c", "http.lowSpeedTime=20" }
  if USE_MIRROR then
    vim.list_extend(cmd, { "-c", ("url.%shttps://github.com/.insteadOf=https://github.com/"):format(MIRROR) })
  end
  return vim.list_extend(cmd, args)
end

for _, p in ipairs(plugins) do
  local path = pack_dir .. p.name
  if vim.fn.isdirectory(path) == 0 then
    vim.notify("正在下载插件: " .. p.name .. " ...")
    vim.fn.system(git({ "clone", "--depth", "1", p.src, path }))
    if vim.v.shell_error ~= 0 then
      vim.fn.delete(path, "rf")            -- 删掉残缺目录，下次启动会重新下载
      vim.notify("下载失败: " .. p.name .. "（重启 Neovim 会再试）", vim.log.levels.WARN)
    else
      vim.opt.runtimepath:append(path)     -- 只有刚装的插件需要手动加入
      pcall(vim.cmd.helptags, path .. "/doc")
    end
  end
end

vim.api.nvim_create_user_command("PluginUpdate", function()
  local pending = #plugins
  local function done()
    pending = pending - 1
    if pending == 0 then
      pcall(vim.cmd, "helptags ALL")
      vim.notify("🎉 插件更新完成，重启 Neovim 生效")
    end
  end
  for _, p in ipairs(plugins) do
    local dir = pack_dir .. p.name
    if vim.fn.isdirectory(dir) == 0 then
      vim.notify(p.name .. " 未安装，重启 Neovim 即可安装", vim.log.levels.WARN)
      done()
    else
      -- 把旧的地址 (echasnovski / 带镜像前缀的) 统一改回真实地址
      vim.fn.system({ "git", "-C", dir, "remote", "set-url", "origin", p.src })
      vim.system(git({ "-C", dir, "pull", "--ff-only" }), { text = true }, function(r)
        vim.schedule(function()
          if r.code ~= 0 then
            vim.notify("更新失败 " .. p.name .. ":\n" .. (r.stderr or ""), vim.log.levels.ERROR)
          end
          done()
        end)
      end)
    end
  end
end, {})

vim.api.nvim_create_user_command("PluginClean", function()
  local keep = {}
  for _, p in ipairs(plugins) do keep[p.name] = true end
  for name, type in vim.fs.dir(pack_dir) do
    if type == "directory" and not keep[name] then
      vim.fn.delete(pack_dir .. name, "rf")
      vim.notify("已删除: " .. name)
    end
  end
end, {})

----------------------------------------------------------------------
-- 1. 选项 (hlsearch/incsearch/autoread/wildmenu/showcmd/termguicolors 已默认开启)
----------------------------------------------------------------------
local o = vim.o

o.number       = true                     -- 绝对行号
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

o.expandtab, o.shiftwidth, o.tabstop, o.softtabstop = true, 4, 4, 4
o.smartindent, o.shiftround = true, true

o.ignorecase, o.smartcase = true, true

o.undofile     = true
o.confirm      = true
o.fileencoding = "utf-8"
o.fileencodings = "utf-8,gbk,big5,ucs-bom"

o.foldmethod, o.foldlevel = "indent", 99

o.timeoutlen   = 400
o.switchbuf    = "useopen,usetab,newtab"
o.clipboard    = "unnamedplus"
o.splitright, o.splitbelow = true, true
o.completeopt  = "menu,menuone,noselect,popup,fuzzy"
o.path         = o.path .. ",**"
o.wildignore   = "*/node_modules/*,*/.git/*,*/target/*,*/dist/*,*.o,*.pyc"
o.wildoptions  = "pum,fuzzy"
o.wildmode     = "longest:full,full"

o.formatlistpat = [[^\s*\(\d\+\|[-*]\)\+[\]:.)}\t ]\s*]]
vim.opt.formatoptions:append("n")

vim.g.netrw_banner, vim.g.netrw_liststyle = 0, 3
vim.g.netrw_browse_split, vim.g.netrw_winsize = 0, 25

----------------------------------------------------------------------
-- 2. 主题：内置 retrobox (Gruvbox 风格，深浅两色)；备选 default / habamax / unokai
----------------------------------------------------------------------
vim.cmd.colorscheme("retrobox")
map("n", "<F9>", function()
  o.background = o.background == "dark" and "light" or "dark"
end, { desc = "Toggle dark/light" })

----------------------------------------------------------------------
-- 3. mini.nvim
----------------------------------------------------------------------
require("mini.starter").setup()
require("mini.pairs").setup()
require("mini.ai").setup({ n_lines = 500 })
require("mini.extra").setup()
require("mini.git").setup()
require("mini.diff").setup({ view = { style = "sign" } })
require("mini.statusline").setup({ use_icons = false })

-- 查找 + 接管 vim.ui.select (Overseer 的选择框也用它)
require("mini.pick").setup()
vim.ui.select = MiniPick.ui_select

-- 包围：只用 ms / md / mr 三个键，其余全部关闭，少占按键
require("mini.surround").setup({
  mappings = {
    add = "ms", delete = "md", replace = "mr",
    find = "", find_left = "", highlight = "", update_n_lines = "",
  },
  custom_surroundings = {   -- 同 Helix：左括号也不加内侧空格
    ["("] = { output = { left = "(", right = ")" } },
    ["["] = { output = { left = "[", right = "]" } },
    ["{"] = { output = { left = "{", right = "}" } },
    ["<"] = { output = { left = "<", right = ">" } },
  },
  search_method = "cover_or_next",
})
map({ "n", "x" }, "mm", "%",  { desc = "Goto matching bracket" })
map("n", "mi", "vi", { remap = true, desc = "Select inside" })
map("n", "ma", "va", { remap = true, desc = "Select around" })

-- 按键提示
local clue = require("mini.clue")
clue.setup({
  triggers = {
    { mode = "n", keys = "<Leader>" }, { mode = "x", keys = "<Leader>" },
    { mode = "n", keys = "g" },        { mode = "x", keys = "g" },
    { mode = "n", keys = "m" },        { mode = "x", keys = "m" },
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

----------------------------------------------------------------------
-- 4. 多光标 (Helix 风格)
----------------------------------------------------------------------
local mc = require("multicursor-nvim")
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

map("x", "s", mc.matchCursors, { desc = "Select regex in selection" })
map("x", "S", mc.splitCursors, { desc = "Split selection by regex" })
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
vim.api.nvim_create_autocmd("ColorScheme", { callback = mc_hl })

----------------------------------------------------------------------
-- 5. Overseer (v2)
----------------------------------------------------------------------
local overseer = require("overseer")
overseer.setup({
  task_list = { direction = "right", min_width = 35, max_width = 45 },
})

map("n", "<leader>or", "<cmd>OverseerRun<cr>",        { desc = "Run task" })
map("n", "<leader>oo", "<cmd>OverseerToggle<cr>",     { desc = "Task list" })
map("n", "<leader>oa", "<cmd>OverseerTaskAction<cr>", { desc = "Task action" })
map("n", "<leader>os", ":OverseerShell ",             { desc = "Shell cmd as task" })
map("n", "<leader>ol", function()
  local last
  for _, t in ipairs(overseer.list_tasks()) do
    if not last or t.id > last.id then last = t end
  end
  if last then overseer.run_action(last, "restart")
  else vim.notify("No tasks", vim.log.levels.WARN) end
end, { desc = "Restart last task" })

----------------------------------------------------------------------
-- 6. 通用快捷键
----------------------------------------------------------------------
map("n", "<Esc>", "<cmd>nohlsearch<cr><Esc>")          -- 有多光标时由上面的按键层接管
map({ "n", "i", "v", "s" }, "<C-g>", "<Esc>")
map("c", "<C-g>", "<C-c>")
map({ "n", "x" }, "<C-z>", ":")
map("i", "<C-z>", "<C-o>:")
map("n", "<C-F4>", "<C-w>c")
map("i", "<C-F4>", "<Esc><C-w>c")
map("c", "<C-F4>", "<C-c><C-w>c")

map("n", "<leader>w", "<cmd>w<cr>", { desc = "Write" })
map("n", "<leader>q", "<cmd>q<cr>", { desc = "Quit" })
map({ "n", "v", "i" }, "<C-s>", "<cmd>update<cr>")
map("n", "-", "<cmd>Explore<cr>")

map({ "n", "x" }, "j", "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })
map({ "n", "x" }, "k", "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
map({ "n", "x" }, "<Down>", "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })
map({ "n", "x" }, "<Up>",   "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
map("i", "<Down>", "<C-o>gj")
map("i", "<Up>",   "<C-o>gk")
map({ "n", "v" }, "<Home>", "^")
map({ "n", "v" }, "<End>",  "$")
map("n", "<PageUp>", "{")
map("n", "<PageDown>", "}")

map("n", "\\", [[:%s/\<<C-r><C-w>\>//gc<Left><Left><Left>]], { desc = "Replace word" })
map("n", "<leader>cd", "<cmd>cd %:p:h<cr><cmd>pwd<cr>", { desc = "cd to file dir" })
map("n", "<F10>", "<cmd>setlocal spell!<cr>")

map("i", "<C-BS>", "<C-w>")
map("i", "<C-Del>", "<C-o>dw")

map("n", "<C-h>", "<C-w>h")
map("n", "<C-j>", "<C-w>j")
map("n", "<C-k>", "<C-w>k")
map("n", "<C-l>", "<C-w>l")

map("n", "<M-j>", "<cmd>m .+1<cr>==")
map("n", "<M-k>", "<cmd>m .-2<cr>==")
map("v", "<M-j>", ":m '>+1<cr>gv=gv")
map("v", "<M-k>", ":m '<-2<cr>gv=gv")
map("x", "p", "P")
map("x", "P", "p")

map("i", "<C-d>", function() return os.date("%Y-%m-%d %H:%M:%S") end, { expr = true })
map("i", "<M-=>", "<Esc>A;<CR>")
map("i", "<M-->", "<Esc>A:<CR>")

-- 查找
map("n", "<leader>ff", "<cmd>Pick files<cr>",      { desc = "Files" })
map("n", "<leader>fg", "<cmd>Pick grep_live<cr>",  { desc = "Live grep" })
map("n", "<leader>fb", "<cmd>Pick buffers<cr>",    { desc = "Buffers" })
map("n", "<leader>fh", "<cmd>Pick help<cr>",       { desc = "Help" })
map("n", "<leader>fo", "<cmd>Pick oldfiles<cr>",   { desc = "Recent files" })
map("n", "<leader>fd", "<cmd>Pick diagnostic<cr>", { desc = "Diagnostics" })
map("n", "<leader>fl", "<cmd>Pick buf_lines<cr>",  { desc = "Buffer lines" })
map("n", "<leader>fr", "<cmd>Pick resume<cr>",     { desc = "Resume" })

-- Git
map("n", "<leader>go", function() MiniDiff.toggle_overlay() end, { desc = "Diff overlay" })
map({ "n", "x" }, "<leader>gs", function() MiniGit.show_at_cursor() end, { desc = "Git at cursor" })

-- Tab 补全：菜单中→下一项；行首/空白后→缩进；否则→LSP 或关键字补全
map("i", "<Tab>", function()
  if vim.fn.pumvisible() == 1 then return "<C-n>" end
  local col = vim.fn.col(".") - 1
  if col == 0 or vim.fn.getline("."):sub(col, col):match("%s") then return "<Tab>" end
  return vim.bo.omnifunc ~= "" and "<C-x><C-o>" or "<C-n>"
end, { expr = true })
map("i", "<S-Tab>", function()
  return vim.fn.pumvisible() == 1 and "<C-p>" or "<S-Tab>"
end, { expr = true })

----------------------------------------------------------------------
-- 7. 注释装饰 (F11 分隔线 / F12 文件头)
----------------------------------------------------------------------
local DECO = { width = 80, author = "the one", rule = "-", head = "=" }
local dw = vim.fn.strdisplaywidth

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

map({ "n", "i" }, "<F11>", function()
  local row = vim.api.nvim_win_get_cursor(0)[1]
  local insert = vim.api.nvim_get_mode().mode:sub(1, 1) == "i"
  local blank = vim.trim(vim.api.nvim_get_current_line()) == ""
  local start, finish = row, row
  if not insert and blank then start = row - 1 end      -- 普通模式空行：直接替换该行
  vim.api.nvim_buf_set_lines(0, start, finish, false, { rule_line(DECO.rule) })
  vim.api.nvim_win_set_cursor(0, { start + 1, 0 })
end, { desc = "Separator line" })

map({ "n", "i" }, "<F12>", function()
  local prefix = comment_parts()
  local first  = vim.api.nvim_buf_get_lines(0, 0, 1, false)[1] or ""
  if first:match("^%s*" .. vim.pesc(prefix) .. "%s*" .. DECO.head) then
    return vim.notify("File header already exists", vim.log.levels.WARN)
  end
  local name = vim.fn.expand("%:t")
  local bar = rule_line(DECO.head)
  local header = {
    bar,
    text_line("File    : " .. (name ~= "" and name or "[No Name]")),
    text_line("Created : " .. os.date("%Y-%m-%d %H:%M:%S")),
    text_line("Author  : " .. DECO.author),
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
local au = vim.api.nvim_create_autocmd
local group = vim.api.nvim_create_augroup("UserConfig", { clear = true })

au("TextYankPost", { group = group, callback = function() vim.hl.on_yank({ timeout = 200 }) end })

-- 恢复上次光标位置
au("BufReadPost", {
  group = group,
  callback = function(args)
    local mark = vim.api.nvim_buf_get_mark(args.buf, '"')
    if mark[1] > 0 and mark[1] <= vim.api.nvim_buf_line_count(args.buf) then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
      vim.cmd("normal! zz")
    end
  end,
})

-- 自动切换到项目根目录 (找不到就用文件所在目录)；Overseer / Pick 都依赖 cwd
local root_markers = { ".git", "Makefile", "justfile", "package.json", "pyproject.toml",
                       "Cargo.toml", "pubspec.yaml", ".vscode" }
au("BufEnter", {
  group = group,
  callback = function(args)
    if vim.bo[args.buf].buftype ~= "" then return end
    local name = vim.api.nvim_buf_get_name(args.buf)
    if name == "" then return end
    local root = vim.fs.root(args.buf, root_markers) or vim.fs.dirname(name)
    if root and root ~= vim.fn.getcwd() and vim.fn.isdirectory(root) == 1 then
      vim.fn.chdir(root)
    end
  end,
})

-- 保存时去掉行尾空白 (markdown / diff 除外)
au("BufWritePre", {
  group = group,
  callback = function(args)
    local ft = vim.bo[args.buf].filetype
    if ft == "markdown" or ft == "diff" then return end
    local view = vim.fn.winsaveview()
    vim.cmd([[keeppatterns silent! %s/\s\+$//e]])
    vim.fn.winrestview(view)
  end,
})

-- 大文件 (>5MB) 降级
au("BufReadPre", {
  group = group,
  callback = function(args)
    local st = vim.uv.fs_stat(args.file)
    if st and st.size > 5 * 1024 * 1024 then
      vim.b[args.buf].bigfile = true
      vim.b[args.buf].minidiff_disable = true
      vim.bo[args.buf].undofile = false
      vim.bo[args.buf].swapfile = false
    end
  end,
})

-- 有 treesitter 解析器就用它高亮，没有就用传统 syntax；大文件关闭高亮
au("FileType", {
  group = group,
  callback = function(args)
    if vim.b[args.buf].bigfile then
      vim.schedule(function() vim.bo[args.buf].syntax = "OFF" end)
      return
    end
    pcall(vim.treesitter.start, args.buf)
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
  if vim.fn.executable(cfg.cmd[1]) == 1 then       -- 没装的服务器直接跳过
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
-- 10. LaTeX (交给 Overseer 运行：输出可在 <Space>oo 查看，完成后自动通知)
----------------------------------------------------------------------
local function latexmk(args, title)
  local file = vim.api.nvim_buf_get_name(0)
  if file == "" or vim.fn.filereadable(file) == 0 then
    return vim.notify("Current file does not exist.", vim.log.levels.ERROR)
  end
  vim.cmd("silent update")
  local cmd = vim.list_extend({ "latexmk" }, args)
  table.insert(cmd, file)
  overseer.new_task({
    name = title, cmd = cmd, cwd = vim.fs.dirname(file), components = { "default" },
  }):start()
end

local tex = { "-xelatex", "-interaction=nonstopmode", "-halt-on-error" }
map("n", "<leader>tt", function() latexmk(tex, "LaTeX compile") end, { desc = "Compile" })
map("n", "<leader>te", function() latexmk(vim.list_extend({ "-gg" }, tex), "LaTeX rebuild") end, { desc = "Full rebuild" })
map("n", "<leader>tc", function() latexmk({ "-C" }, "LaTeX clean") end, { desc = "Clean aux" })
map("n", "<leader>tv", function()
  local pdf = vim.fn.expand("%:p:r") .. ".pdf"
  if vim.fn.filereadable(pdf) == 0 then
    return vim.notify("PDF not found. Compile first (<Space>tt).", vim.log.levels.WARN)
  end
  for _, v in ipairs({ "okular", "evince", "zathura", "xdg-open" }) do
    if vim.fn.executable(v) == 1 then
      vim.system({ v, pdf }, { detach = true })
      return vim.notify("Opening PDF with " .. v)
    end
  end
  vim.notify("No PDF viewer found.", vim.log.levels.ERROR)
end, { desc = "View PDF" })

----------------------------------------------------------------------
-- 11. Neovide
----------------------------------------------------------------------
o.guifont = "Hack:h14"

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

  local size = 14
  local function font(n) size = n; o.guifont = ("Hack:h%d"):format(n) end
  map("n", "<C-=>", function() font(size + 1) end)
  map("n", "<C-->", function() font(math.max(6, size - 1)) end)
  map("n", "<C-0>", function() font(14) end)
end
