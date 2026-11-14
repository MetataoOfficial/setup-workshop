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
# sudo pacman -S starship zoxide fzf trash-cli tree bsdtar yazi
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
set paths = [~/.local/bin ~/go/bin /opt/miniconda3/bin /var/lib/snapd/snap/bin $@paths]
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

fn cltex {
    try {
        rm -f *.{aux,toc,fls,log,out,xdv,fdb_latexmk,synctex.gz}
    } catch _ {
        echo "Found no LaTeX aux files"
    }
}

# 文件管理
fn md {|@dirs| e:mkdir -p -- $@dirs }
fn yz {|@args|
    var tmp = (mktemp -t yazi-cwd.XXXXXX)
    try {
        e:yazi $@args --cwd-file=$tmp
        if (path:is-regular $tmp) {
            var cwd = (cat $tmp)
            if (and (not-eq $cwd $pwd) (path:is-dir $cwd)) {
                cd $cwd
            }
        }
    } finally {
        rm -f $tmp
    }
}

fn !   { cd .. }
fn !!  { cd ../.. }
fn !!! { cd ../../.. }

fn del {|@a| e:trash-put $@a }    # 恢复：trash-list / trash-restore
fn fe  {|@a| try { e:nvim (e:fzf $@a) } catch { } }   # Esc 取消
fn ex  {|f| e:bsdtar -xf $f }     # 支持 tar.gz/xz/bz2/zst、zip、7z 等

fn py   {|@a| e:python  $@a }
fn ipy  {|@a| e:ipython $@a }
fn pipi {|@a| e:python -m pip install $@a }

# 7. 本机私有配置（token、代理等，不放进 git）
var local-rc = ~/.config/elvish/local.elv
if (path:is-regular $local-rc) {
    eval (slurp < $local-rc)
}

# 8. 进程替换：模拟 Bash 的 diff <(cat a) <(cat b) 或 Fish 的 diff (cat a | psub) (cat b | psub)
var -psub-files = []

fn psub {|&suffix=''|
    # 创建临时文件（支持可选后缀，方便某些按扩展名识别格式的程序，如 diff/vim/jq）
    var tmp = (mktemp /tmp/elvish-psub.XXXXXXXXXX$suffix)

    # 将标准输入完整写入临时文件，使用 only-bytes 保证二进制或纯文本原样落盘
    only-bytes > $tmp

    # 将文件路径加入待清理列表
    set -psub-files = [$@-psub-files $tmp]

    # 输出临时文件路径给外层命令
    put $tmp
}

# 注册钩子：每当整行命令执行完毕、准备显示下一次提示符时，自动清理所有临时文件
set edit:before-readline = [$@edit:before-readline {
    if (not-eq $-psub-files []) {
        rm -f $@-psub-files
        set -psub-files = []
    }
}]

# 使用示例：
# 1. 通用命令输出对比：diff (sort file1.txt | psub) (sort file2.txt | psub)
# 2. 对比远程 JSON 接口：diff (curl -s https://example.com | jq . | psub) (curl -s https://example.com | jq . | psub)
# 3. 带后缀名使用：some-tool (generate-data | psub &suffix=.json)
