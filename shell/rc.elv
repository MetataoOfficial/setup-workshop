# ~/.config/elvish/rc.elv   —— 兼容 Elvish 0.20
#
# ── 速查 ──────────────────────────────────────────────────────
# 编辑   Ctrl-A/E 行首/尾  Ctrl-W 删词  Ctrl-U/K 删到行首/尾  Ctrl-L 清屏
# 历史   Ctrl-R 搜索  ↑ 前缀匹配  Alt-1 插入上条命令/参数
# 目录   z foo 跳转  zi 交互选择  Alt-L 常去目录  Ctrl-N 浏览文件
#        ! !! !!! 上 1/2/3 级   mcd 建目录并进入
# 文件   ll la lt 列表   fe 模糊找文件并编辑   del 移到回收站   ex 解压
# 缩写   g→git  v→nvim  ||→| less  >dn→> /dev/null 2>&1
# Python py ipy pipi
#
# ── 安装（Manjaro）────────────────────────────────────────────
#   sudo pacman -S --needed starship zoxide fzf trash-cli tree bsdtar
#
# ── 一次性设置（写进各工具自己的配置，不用放在 rc 里）────────
#   go env -w GOPROXY=https://goproxy.cn,direct
#   pip config set global.index-url https://pypi.tuna.tsinghua.edu.cn/simple
# ──────────────────────────────────────────────────────────────

# 0. 导入
use str
use path
use epm
use readline-binding

epm:install &silent-if-installed github.com/xiaq/edit.elv

# 1. 环境变量
set-env EDITOR nvim
set-env VISUAL nvim
set-env LESS '-R -F -X -i'

# 2. PATH：前置常用目录，去掉不存在的目录和重复项
set paths = [~/.local/bin ~/go/bin /opt/miniconda3/bin $@paths]
var seen = [&]
set paths = [(for p $paths {
    if (and (path:is-dir $p) (not (has-key $seen $p))) {
        set seen[$p] = $true
        put $p
    }
})]

# 3. 插件：补全时先按前缀匹配，匹配不到再用模糊匹配
use github.com/xiaq/edit.elv/smart-matcher
smart-matcher:apply

# 4. 外部工具（没装的会自动跳过）
if (has-external starship) {
    eval (starship init elvish | slurp)
}

if (has-external zoxide) {
    eval (zoxide init elvish | slurp)
}

# 5. 编辑器行为
set edit:insert:binding[Alt-Backspace] = { edit:kill-small-word-left }
set edit:insert:binding[Ctrl-L]        = { edit:clear }
set edit:insert:binding[Alt-l]         = { edit:location:start }

set edit:command-abbr['g'] = 'git'
set edit:command-abbr['v'] = 'nvim'
set edit:abbr['||']        = '| less'
set edit:abbr['>dn']       = '> /dev/null 2>&1'

set notify-bg-job-success = $false

# 终端标题：空闲时显示当前目录，运行命令时显示命令名
set edit:before-readline = [$@edit:before-readline {
    print "\e]0;tty: "(tilde-abbr $pwd)"\a" > /dev/tty
}]

set edit:after-readline = [$@edit:after-readline {|cmd|
    var w = [(str:fields $cmd)]
    if (> (count $w) 0) { print "\e]0;tty: "$w[0]"\a" > /dev/tty }
}]

# 6. 常用函数（Elvish 脚本不会加载 rc.elv，不影响脚本）
fn ll {|@a| e:ls -lh  --color=auto --group-directories-first $@a }
fn la {|@a| e:ls -lAh --color=auto --group-directories-first $@a }
fn lt {|@a| e:tree -L 2 $@a }

fn md {|@dirs| e:mkdir -p -- $@dirs }
fn !   { cd .. }
fn !!  { cd ../.. }
fn !!! { cd ../../.. }

fn del {|@a| e:trash-put $@a }    # 恢复：trash-list / trash-restore
fn fe  {|@a| try { e:nvim (e:fzf $@a) } catch { } }   # Esc 取消
# fn ex  {|f| e:bsdtar -xf $f }     # 支持 tar.gz/xz/bz2/zst、zip、7z 等

fn py   {|@a| e:python  $@a }
fn ipy  {|@a| e:ipython $@a }
fn pipi {|@a| e:python -m pip install $@a }

# 7. 本机私有配置（token、代理等，不放进 git）
var local-rc = ~/.config/elvish/local.elv
if (path:is-regular $local-rc) {
    eval (slurp < $local-rc)
}
