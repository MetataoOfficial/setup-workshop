# ~/.config/elvish/rc.elv

use os
use re
use str
use epm
use path
use math
use readline-binding  # 提供类似 Bash/Zsh 的快捷键 (Ctrl-A, Ctrl-E 等)


set-env EDITOR nvim
set paths = [
    /opt/miniconda3/bin
    ~/go/bin
    $@paths
]


# epm:install &silent-if-installed ^
#     github.com/xiaoq/edit.elv ^
#     github.com/muesli/elvish-libs

# # 设置提示符 (必须接收两个参数)
# set edit:prompt = {|_left _right|
#     styled " > " green
# }
#
# # 自定义键位绑定
# edit:insert:binding[Alt-Backspace] = { edit:kill-word-left }


fn ll {|@args| ls -l $@args }
fn md {|@args| mkdir -p $@args }
# fn rm {|@args| rm -i $@args } # not good for scripts
# fn mv {|@args| mv -i $@args }
# fn cp {|@args| cp -i $@args }

fn py   {|@args| /opt/miniconda3/bin/python $@args }
fn ipy  {|@args| /opt/miniconda3/bin/ipython $@args }
fn pipi {|@args| /opt/miniconda3/bin/pip install -i https://pypi.tuna.tsinghua.edu.cn/simple $@args }
# 提示:: 可以通过以下方式配置镜像源:
# Pip:   编辑 ~/.config/pip/pip.conf [global] index-url = https://pypi.tuna.tsinghua.edu.cn/simple
# Conda: 运行 conda config --add channels https://mirrors.tuna.tsinghua.edu.cn/anaconda/pkgs/main/


# 快速返回上级目录
fn ! { cd .. }
fn !! { cd ../.. }
fn !!! { cd ../../.. }
