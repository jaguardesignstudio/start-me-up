#!/bin/bash

###############################
# SETUP AND UTILITY FUNCTIONS #
###############################

# OS detection
OS='unknown'
unamestr=`uname`
if [[ "$unamestr" == 'Linux' ]]; then
  OS='linux'
elif [[ "$unamestr" == 'Darwin' ]]; then
  OS='mac'
fi

# Colors
CLEAR="\033[0m"
ORANGE="\033[33m"

# Utility functions
distro_name() {
  lsb_release --codename --short
}

result() {
  $* || (echo "failed" 1>&2 && exit 1)
  echo
}

output() {
  echo -e ${ORANGE}$1${CLEAR}
}

version_check() {
  if lsb_release -c | grep -qEv 'precise|quantal|wheezy|raring|saucy'
  then
    output "Sorry! We don't currently support this distro."
    exit;
  fi
}

binary_check() {
  if command -v $1 >/dev/null; then
    shift
    "$@"
  fi
}

ask_prompt() {
  read -p "$1 [y/N]" answer
  if [[ $answer = y ]] ; then
    "$@"
  fi
}
apt_install() {
  result sudo apt-get install -y "$@"
}

brew_install() {
  result brew install "$@"
}

cask_install() {
  result brew cask install "$@"
}

deb_install() {
  wget $1 -qO /tmp/tmp.deb
  sudo dpkg -i /tmp/tmp.deb
  rm /tmp/tmp.deb
}

apt_update() {
  sudo apt-get update > /dev/null
}

apt_upgrade() {
  sudo apt-get -y upgrade
}

add_apt() {
  sudo add-apt-repository -y $1
  apt_update
}

install() {
  if [[ $OS == 'linux' ]]; then
    apt_install "$@"
  elif [[ $OS == 'mac' ]]; then
    brew_install "$@"
  fi
}

git_install() {
  if [ ! -d $2 ]; then
    git clone $1 $2
  fi
}

add_apt_list() {
  if test ! -f /etc/apt/sources.list.d/$2.list; then
    sudo echo "$1" | sudo tee /etc/apt/sources.list.d/$2.list > /dev/null
  fi
}

apt_key() {
  wget -q -O - $1 | sudo apt-key add - > /dev/null
}

rbenv_config() {
  if [[ $OS == 'mac' ]]; then
    echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.bash_profile
    echo 'eval "$(rbenv init -)"' >> ~/.bash_profile
  elif [[ $OS == 'linux' ]]; then
    echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.bashrc
    echo 'eval "$(rbenv init -)"' >> ~/.bashrc
  fi
  echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.zshrc
  echo 'eval "$(rbenv init -)"' >> ~/.zshrc
}

pyenv_config() {
  if [[ $OS == 'mac' ]]; then
    echo 'export PATH="$HOME/.pyenv/bin:$PATH"' >> ~/.bash_profile
    echo 'eval "$(pyenv init -)"' >> ~/.bash_profile
  elif [[ $OS == 'linux' ]]; then
    echo 'export PATH="$HOME/.pyenv/bin:$PATH"' >> ~/.bashrc
    echo 'eval "$(pyenv init -)"' >> ~/.bashrc
  fi
  echo 'export PATH="$HOME/.pyenv/bin:$PATH"' >> ~/.zshrc
  echo 'eval "$(pyenv init -)"' >> ~/.zshrc
}

################
# START ME UP! #
################

# If Linux, make sure this is a Ubuntu or Debian we know
if [[ $OS == 'linux' ]]; then
  version_check
fi

if [[ $OS == 'linux' ]]; then
  output "Linux: enabling multiarch"
  sudo dpkg --add-architecture i386
fi

if [[ $OS == 'linux' ]]; then
  output "Linux: Updating package cache, upgrading installed packages"
  apt_update
  apt_upgrade
fi

if [[ $OS == 'mac' ]]; then
  output "Mac: installing Xcode"
  bash <(curl -s https://raw.github.com/timsutton/osx-vm-templates/master/scripts/xcode-cli-tools.sh)
fi

if [[ $OS == 'mac' ]]; then
  output "Installing Homebrew"
  ruby -e "$(curl -fsSL https://raw.github.com/mxcl/homebrew/go)"
  output "Installing Casks, Homebrew addon for GUI apps"
  brew tap phinze/homebrew-cask
  brew_install brew-cask
fi

if [[ $OS == 'linux' ]]; then
  output "Linux: Installing development packages"
  apt_install build-essential bison openssl libreadline6 libreadline6-dev zlib1g zlib1g-dev libssl-dev libyaml-dev libxml2-dev libxslt-dev autoconf libc6-dev automake cmake
fi

output "Installing zsh"
if [[ $OS == 'linux' ]]; then
  apt_install zsh
  ask_prompt "Do you want to set zsh as your default shell?" "chsh -s /usr/bin/zsh"
elif [[ $OS == 'mac' ]]; then
  brew_install zsh reattach-to-user-namespace
  sudo mv /etc/zshenv /etc/zprofile
  echo "/usr/local/bin/zsh" | sudo tee -a /etc/shells
  ask_prompt "Do you want to set zsh as your default shell?" "chsh -s /usr/local/bin/zsh"
fi

output "Installing version control clients"
install git subversion

output "Installing tmux"
install tmux

output "Installing htop"
if [[ $OS == 'linux' ]]; then
  apt_install htop
elif [[ $OS == 'mac' ]]; then
  brew_install htop-osx
fi

output "Installing PgAdmin3"
install pgadmin3

output "Installing vim (latest)"
if [[ $OS == 'linux' ]]; then
  add_apt ppa:dgadomski/vim-daily
  apt_install vim vim-gnome
elif [[ $OS == 'mac' ]]; then
  brew_install macvim --HEAD --override-system-vim --with-cscope --with-lua
fi

output "Installing Sublime Text"
if [[ $OS == 'linux' ]]; then
  add_apt ppa:webupd8team/sublime-text-2
  apt_update
  apt_install sublime-text
elif [[ $OS == 'mac' ]]; then
  cask_install sublime-text
fi

output "Installing ctags"
if [[ $OS == 'linux' ]]; then
  apt_install exuberant-ctags
elif [[ $OS == 'mac' ]]; then
  brew_install ctags
fi

output "Installing ack and ag (The Silver Searcher)"
if [[ $OS == 'linux' ]]; then
  apt_install ack-grep silversearcher-ag
elif [[ $OS == 'mac' ]]; then
  brew_install ack the_silver_searcher
fi

if [[ $OS == 'linux' ]]; then
  output "Installing Synapse"
  apt_install synapse
elif [[ $OS == 'mac' ]]; then
  output "Installing Alfred"
  cask_install alfred
fi

output "Installing Google Chrome"
if [[ $OS == 'linux' ]]; then
  apt_key https://dl-ssl.google.com/linux/linux_signing_key.pub
  add_apt_list "deb http://dl.google.com/linux/chrome/deb/ stable main" google-chrome
  apt_update
  apt_install google-chrome-stable
elif [[ $OS == 'mac' ]]; then
  cask_install google-chrome
fi

output "Installing rbenv and plugins"
git_install https://github.com/sstephenson/rbenv.git ~/.rbenv
git_install https://github.com/sstephenson/ruby-build.git ~/.rbenv/plugins/ruby-build
git_install git://github.com/tpope/rbenv-ctags.git ~/.rbenv/plugins/rbenv-ctags
git_install https://github.com/sstephenson/rbenv-default-gems.git ~/.rbenv/plugins/rbenv-default-gems
git_install https://github.com/rkh/rbenv-update.git ~/.rbenv/plugins/rbenv-update
if [[ $OS == 'mac' ]]; then
  git_install git://github.com/tpope/rbenv-readline.git ~/.rbenv/plugins/rbenv-readline
fi
ask_prompt "Add rbenv to your bash/zsh config? (Choose yes only if this is a fresh install of rbenv, not an update)", rbenv_config

output "Installing pyenv and plugins"
git_install git://github.com/yyuu/pyenv.git ~/.pyenv
git_install git://github.com/yyuu/pyenv-virtualenv.git ~/.pyenv/plugins/pyenv-virtualenv
ask_prompt "Add pyenv to your bash/zsh config? (Choose yes only if this is a fresh install of pyenv, not an update)", pyenv_config

output "Installing Virtualbox and Vagrant"
if [[ $OS == 'linux' ]]; then
  apt_key http://download.virtualbox.org/virtualbox/debian/oracle_vbox.asc
  add_apt_list "deb http://download.virtualbox.org/virtualbox/debian $(distro_name) contrib" virtualbox
  apt_update
  apt_install virtualbox-4.3
  # Vagrant, y u no apt repo?
  deb_install http://files.vagrantup.com/packages/a40522f5fabccb9ddabad03d836e120ff5d14093/vagrant_1.3.5_x86_64.deb
elif [[ $OS == 'mac' ]]; then
  cask_install virtualbox
  cask_install vagrant
fi

output "Installing rcm"
if [[ $OS == 'linux' ]]; then
  deb_install http://mike-burns.com/project/rcm/rcm_1.1.0_all.deb
elif [[ $OS == 'mac' ]]; then
  brew tap mike-burns/rcm
  brew_install rcm
fi

if [[ $OS == 'linux' ]]; then
  output "Linux: Font packages"
  apt_install ttf-mscorefonts-installer fonts-inconsolata fonts-opensymbol mathematica-fonts
  output "Linux: Installing Typecatcher for access to Google Webfonts"
  add_apt ppa:andrewsomething/typecatcher
  apt_update
  apt_install typecatcher
fi

output "Installing HipChat"
if [[ $OS == 'linux' ]]; then
  apt_key https://www.hipchat.com/keys/hipchat-linux.key
  add_apt_list "deb http://downloads.hipchat.com/linux/apt stable main" atlassian-hipchat
  apt_update
  apt_install hipchat
elif [[ $OS == 'mac' ]]; then
  cask_install hipchat
fi

output "Installing Dropbox"
if [[ $OS == 'linux' ]]; then
  if ! command -v dropbox > /dev/null; then
    deb_install https://www.dropbox.com/download?dl=packages/ubuntu/dropbox_1.6.0_amd64.deb
  fi
elif [[ $OS == 'mac' ]]; then
  cask_install dropbox
fi

if [[ $OS == 'mac' ]]; then
  output "Installing Harvest time tracking widget"
  cask_install harvest
fi

# vim: set ft=bash
