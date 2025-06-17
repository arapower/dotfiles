# README.md

dotfiles

## Color Schema

```sh
# Current Directory: Any Directory for Cloning Color Schema Repository
# Clone Color Schema Repository
$ git clone https://github.com/tomasr/molokai.git

# Create Directory for Vim Color Schema
$ mkdir -p ~/.vim/colors

# Create Symbolic link to Color Schema file
$ ln -s $(pwd)/molokai/colors/molokai.vim ~/.vim/colors
```

## Bookmarks

```sh
# Create bookmarks directory
$ mkdir ~/.bookmarks

# Link Directory Shortcut
# ln -s ${some_directory} ${some_shortcut}
```

## NVM

- <https://github.com/nvm-sh/nvm>

```sh
# Install
$ PROFILE=/dev/null bash -c 'curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash'
```

## bat

- <https://github.com/sharkdp/bat>

```sh
# Install on macOS
$ brew install bat

# Install on Ubuntu
$ sudo apt install bat
$ mkdir -p ~/bin
$ ln -s /usr/bin/batcat ~/bin/bat
```

## mpv

- <https://mpv.io/>

```sh
# Install
$ brew install mpv
```
