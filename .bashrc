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
