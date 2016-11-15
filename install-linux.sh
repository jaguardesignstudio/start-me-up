#!/bin/bash

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
  if lsb_release -c | grep -qEv 'precise|quantal|wheezy|raring|saucy|xenial'
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
  if [[ $auto_confirm =~ [Yy] ]] ; then
    true
  else
    read -p "$1 [y/N] " answer
    if [[ $answer =~ [Yy] ]] ; then
      true
    else
      false
    fi
  fi
}

ask_prompt_no_skip() {
  read -p "$1 [y/N] " answer
  if [[ $answer =~ [Yy] ]] ; then
    true
  else
    false
  fi
}

append_if_missing() {
  if ! grep -Fxq "$1" "$2"; then
    echo "$1" >> "$2"
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

# make sure this is a Ubuntu or Debian we know
version_check

output "Enabling multiarch"
sudo dpkg --add-architecture i386

output "Enabling universe/multiverse repos"
add_apt_list "deb http://us.archive.ubuntu.com/ubuntu/ $(distro_name) universe multiverse" universe
add_apt_list "deb http://us.archive.ubuntu.com/ubuntu/ $(distro_name)-updates universe multiverse" universe

output "Updating package cache, upgrading installed packages"
apt_update
apt_upgrade

output "Installing zsh"
apt_install zsh
ask_prompt_no_skip "Do you want to set zsh as your default shell?" && (
  chsh -s /usr/bin/zsh
)

output "Installing development packages"
apt_install build-essential bison openssl libreadline6 libreadline6-dev zlib1g zlib1g-dev libssl-dev libyaml-dev libxml2-dev libxslt-dev autoconf libc6-dev automake cmake libc6-dev libmysql++-dev libsqlite3-dev make phantomjs git subversion gitg nodejs tmux htop pgadmin3 vim exuberant-ctags silversearcher-ag synapse

# TODO: Sublime Text


output "Installing Google Chrome"
apt_key https://dl-ssl.google.com/linux/linux_signing_key.pub
add_apt_list "deb http://dl.google.com/linux/chrome/deb/ stable main" google-chrome
apt_update
apt_install google-chrome-stable

output "Installing Chromium (Dev channel)"
add_apt ppa:saiarcot895/chromium-dev
apt_update
apt_install chromium-browser

output "Installing Firefox"
apt_install firefox

output "Installing Firefox Nightly"
add_apt ppa:ubuntu-mozilla-daily/ppa
apt_update
apt_install firefox-trunk


output "Installing rbenv and plugins"
git_install https://github.com/sstephenson/rbenv.git ~/.rbenv
git_install https://github.com/sstephenson/ruby-build.git ~/.rbenv/plugins/ruby-build
git_install git://github.com/tpope/rbenv-ctags.git ~/.rbenv/plugins/rbenv-ctags
git_install https://github.com/sstephenson/rbenv-default-gems.git ~/.rbenv/plugins/rbenv-default-gems
git_install https://github.com/rkh/rbenv-update.git ~/.rbenv/plugins/rbenv-update
append_if_missing 'export PATH="$HOME/.rbenv/bin:$PATH"' ~/.bashrc
append_if_missing 'eval "$(rbenv init -)"' ~/.bashrc
append_if_missing 'export PATH="$HOME/.rbenv/bin:$PATH"' ~/.zshrc
append_if_missing 'eval "$(rbenv init -)"' ~/.zshrc
# Default gems
echo 'bundler' > ~/.rbenv/default-gems
echo 'gem-ctags' >> ~/.rbenv/default-gems
echo 'gem-browse' >> ~/.rbenv/default-gems
echo 'git-up' >> ~/.rbenv/default-gems
echo 'foreman' >> ~/.rbenv/default-gems
echo 'listen' >> ~/.rbenv/default-gems
echo 'html2haml' >> ~/.rbenv/default-gems
echo 'middleman' >> ~/.rbenv/default-gems
echo 'rubocop' >> ~/.rbenv/default-gems
echo 'paint' >> ~/.rbenv/default-gems
echo 'pry' >> ~/.rbenv/default-gems
echo 'pry-remote' >> ~/.rbenv/default-gems
echo 'pry-coolline' >> ~/.rbenv/default-gems
echo 'awesome_print' >> ~/.rbenv/default-gems
echo 'coderay' >> ~/.rbenv/default-gems

output "Installing Virtualbox and Vagrant"
apt_key http://download.virtualbox.org/virtualbox/debian/oracle_vbox.asc
add_apt_list "deb http://download.virtualbox.org/virtualbox/debian $(distro_name) contrib" virtualbox
apt_update
apt_install virtualbox-4.3
# Vagrant, y u no apt repo?
deb_install https://dl.bintray.com/mitchellh/vagrant/vagrant_1.4.3_x86_64.deb
vagrant plugin install dotenv
vagrant plugin install vagrant-cachier
vagrant plugin install vagrant-vbguest
vagrant plugin install vagrant-vbox-snapshot

output "Font packages"
apt_install ttf-mscorefonts-installer fonts-inconsolata fonts-opensymbol mathematica-fonts
output "Installing Typecatcher for access to Google Webfonts"
add_apt ppa:andrewsomething/typecatcher
apt_update
apt_install typecatcher

output "Installing Dropbox"
if ! command -v dropbox > /dev/null; then
  deb_install https://www.dropbox.com/download?dl=packages/ubuntu/dropbox_1.6.0_amd64.deb
fi

output "Installing Skype"
add_apt_list "deb http://archive.canonical.com/ $(distro_name) partner"
apt_update
apt_install skype

output ""
output "All done! Thanks for using START ME UP"

# vim: set ft=bash
