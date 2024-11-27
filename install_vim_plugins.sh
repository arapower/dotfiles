#!/bin/sh

: 'Create directory for vim plugins' && {
	mkdir -p ~/.vim/pack/plugins/start
}

: 'Clone plugins' && {
	git clone https://github.com/mattn/vim-lsp-settings.git ~/.vim/pack/plugins/start/vim-lsp-settings
	git clone https://github.com/prabirshrestha/asyncomplete.vim.git ~/.vim/pack/plugins/start/asyncomplete.vim
	git clone https://github.com/prabirshrestha/asyncomplete-lsp.vim.git ~/.vim/pack/plugins/start/asyncomplete-lsp.vim
	git clone https://github.com/prabirshrestha/vim-lsp.git ~/.vim/pack/plugins/start/vim-lsp
}
