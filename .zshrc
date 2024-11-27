setopt extended_history

# Prompt
export PS1="%n@%m %F{green}%C%f $ "

# For nvm command
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# For screen command error
export SCREENDIR=$HOME/.screen

# directory for vim cache files
[ -d ~/.vim/tmp ] || mkdir ~/.vim/tmp

# ls: color
#export LSCOLORS=cxfxcxdxbxegedabagacad
export LSCOLORS=gxfxcxdxbxegedabagacad
alias ls='ls -GF'

# grep: color
alias grep='grep --color=auto'
# grep: Exclude some directories
alias grepe='grep --exclude-dir node_modules --exclude-dir .git --exclude-dir .terraform --exclude-dir .terragrunt-cache --color=auto'

unzip_d(){
	# Target Zipped (compressed) file
	zip_file=$1
	# Destination directory
	dest_dir=$(mktemp -d)
	ditto -x -k --sequesterRsrc --rsrc "${zip_file}" "${dest_dir}"
	echo "${dest_dir}"
}

# bat
type bat > /dev/null
[ $? -eq 0 ] && {
	alias cat='bat --paging=never'
}

# Golang
export PATH="$PATH:/usr/local/go/bin"
export PATH="$PATH:$HOME/go/bin"

# User bin
export PATH="$PATH:$HOME/bin"

# bookmark
if [ -d "$HOME/.bookmarks" ]; then
    export CDPATH=".:$HOME/.bookmarks:/"
    alias goto="cd -P"
fi

alias tp='pushd $(mktemp -d)'
alias tm='vi $(mktemp).md'
alias tpm='pushd $(mktemp -d) && vi $(mktemp).md'

alias gcd='git commit -m "$(LANG=C date)"'
alias git_push_f='git push --force-with-lease --force-if-includes'
# Git grep
alias ggrep='git rev-list --all | xargs git grep --heading --line-number -10'
# Character-by-character diff
alias odiff='git diff --word-diff=color --word-diff-regex=.'

# This function generates and executes git diff commands for pairs of commits
# from the specified commit to HEAD.
git_diff_pairs() {
	local commit="$1"
	[ -z "$commit" ] && echo "Usage: git_diff_pairs <commit>" && return 1
	git log "${commit}^..HEAD" --oneline |
	awk '{print $1}' |
	sed -n "N;p;D" |
	paste -d ' ' - - |
	awk '{
		lines[NR] = $0
	}
	
	END {
		for (i = NR; i >= 1; i--) {
			print lines[i]
		}
	}' |
	sed 's/\([^ ][^ ]*\) \([^ ][^ ]*\)/git diff \2..\1/' |
	sh
}

# gh
# 実行する
gh_run(){
	gh workflow run .github/workflows/$1 --ref $(git branch --show-current)
}
# 実行を見守る
gh_watch(){
	gh run list --workflow=$1 | grep $(git branch --show-current) | cut -f 7 | head -n 1 | xargs gh run watch
}
# 結果を確認
gh_view(){
	gh run list --workflow=$1 | grep $(git branch --show-current) | cut -f 7 | head -n 1 | xargs gh run view
}
# ログを確認
gh_log(){
	gh run list --workflow=$1 | grep $(git branch --show-current) | cut -f 7 | head -n 1 | xargs gh run view --log
}

# AWS
aws_p () {
	export AWS_PROFILE="$1"
}

alias mpvl='mpv --loop --no-audio'

# For direnv
eval "$(direnv hook zsh)"
gh auth switch --user arapower
GIT_AUTHOR_NAME='arapower'
GIT_AUTHOR_EMAIL='slothwood@gmail.com'
GIT_COMMITTER_NAME='arapower'
GIT_COMMITTER_EMAIL='slothwood@gmail.com'
export GIT_AUTHOR_NAME
export GIT_AUTHOR_EMAIL
export GIT_COMMITTER_NAME
export GIT_COMMITTER_EMAIL

# For tfenv
export PATH=$PATH:$HOME/.tfenv/bin
export TFENV_AUTO_INSTALL=true

# For tgenv
export PATH=$PATH:$HOME/.tgenv/bin
export TGENV_AUTO_INSTALL=true

# How to use: watch_file_changes "/path/to/directory"
watch_file_changes() {
	p=$(ls -l "$@")
	while true; do
		c=$(ls -l "$@")
		[ "$p" != "$c" ] && echo "Changes detected"
		p="$c"
		sleep 1
	done
}

# For Rust
. "$HOME/.cargo/env"
