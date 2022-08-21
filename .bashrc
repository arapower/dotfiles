# for nvm command
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# For screen command error
export SCREENDIR=$HOME/.screen

# directory for vim cache files
[ -d ~/.vim/tmp ] || mkdir ~/.vim/tmp

# ls: color
alias ls='ls --color=auto'

# grep: color
alias grep='grep --color=auto'

# Golang
export PATH=$PATH:/usr/local/go/bin

# bookmark
if [ -d "$HOME/.bookmarks" ]; then
    export CDPATH=".:$HOME/.bookmarks:/"
    alias goto="cd -P"
fi

alias tp='pushd $(mktemp -d)'
alias tm='vi $(mktemp)'
alias tpm='pushd $(mktemp -d) && vi $(mktemp)'

# Git commit messge with date command
alias gcd='git commit -m "$(LANG=C date)"'

# For Rust
. "$HOME/.cargo/env"
