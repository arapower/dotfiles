setopt extended_history

# Prompt
export PS1="%n@%m %F{green}%C%f $ "

# for nvm command
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
alias grepe='grep --exclude-dir .git --exclude-dir .terraform --color=auto'

# bat
type bat > /dev/null
[ $? -eq 0 ] && {
	alias cat='bat --paging=never'
}

# Golang
export PATH="$PATH:/usr/local/go/bin"
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

# AWS
aws_p () {
	export AWS_PROFILE="$1"
}

alias mpvl='mpv --loop --no-audio'
