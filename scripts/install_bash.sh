#!/bin/sh

: "current_dir" && {
	current_dir=$(d=${0%/*}/; [ "_$d" = "_$0/" ] && d='./'; cd "$d/.."; pwd)
}

ln -s "$current_dir/.vimrc" ~/.vimrc
ln -s "$current_dir/.bashrc" ~/.bashrc

: 'tfenv' && {
	git clone --depth=1 https://github.com/tfutils/tfenv.git ~/.tfenv
	echo 'export PATH=$PATH:$HOME/.tfenv/bin' >> ~/.bashrc
}
