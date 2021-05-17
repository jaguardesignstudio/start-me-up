#!/bin/bash

# Colors
CLEAR="\033[0m"
ORANGE="\033[33m"

output() {
  echo -e ${ORANGE}$1${CLEAR}
}

append_if_missing() {
  if ! grep -Fxq "$1" "$2"; then
    sudo echo "$1" >> "$2"
  fi
}

git_install() {
  if [ ! -d $2 ]; then
    git clone $1 $2
  fi
}

# ensure bash/zsh config files exist
output "Adding shell config files to $HOME"
touch ~/.bash_profile
touch ~/.bashrc
touch ~/.zshrc

# install Ansible
# TODO: move this configuration to Ansible
# if [[ -x $(which ansible) ]]; then
#   output "Ansible already installed, skipping..."
# else
#   output "Installing Ansible"
#   sudo pip install ansible
# fi

# install Xcode
if [[ -x /Applications/Xcode.app ]]; then
  output "Xcode already installed, skipping..."
else
  output "Installing Xcode"
  output ""
  output "Opening Xcode page in App Store in 5 seconds."
  output "Once Xcode is installed, return here and continue."
  sleep 5
  open -n 'macappstore://itunes.apple.com/us/app/xcode/id497799835'
  sleep 10
  read -p "Press Enter once Xcode is fully downloaded and installed..."
  output "Running xcodebuild to accept Xcode license..."
  sudo xcodebuild -license
fi

# Install Xcode Command Line Tools
output "Installing Xcode Command Line Tools"
output ""
xcode-select --install
read -p "Press Enter once Xcode Command Line Tools are fully downloaded and installed..."

# install Homebrew
if [[ -x $(which brew) ]]; then
  output "Homebrew already installed, skipping..."
else
  output "Installing Homebrew"
  ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
  # move /usr/local/bin to the top of /etc/paths
  echo "/usr/local/bin" | cat - /etc/paths | awk '!seen[$0]++' > /tmp/out && sudo mv /tmp/out /etc/paths
  # Set env vars for current shell
  PATH="/usr/local/bin:$PATH"
fi

# install Homebrew bundle and install contents of Brewfile
brew tap Homebrew/bundle
curl -OL https://raw.githubusercontent.com/jaguardesignstudio/start-me-up/master/Brewfile
brew bundle
rm Brewfile

# Add rbenv init
echo 'if which rbenv > /dev/null; then eval "$(rbenv init -)"; fi' >> ~/.bash_profile
echo 'if which rbenv > /dev/null; then eval "$(rbenv init -)"; fi' >> ~/.zprofile

# Add Yarn global bin path to PATH
append_if_missing 'PATH="$PATH:$(yarn global bin)"' ~/.bashrc
append_if_missing 'PATH="$PATH:$(yarn global bin)"' ~/.zshrc
PATH="$PATH:$(yarn global bin)"

# install eslint
yarn global add eslint

# install Vagrant plugins
vagrant plugin install dotenv
vagrant plugin install vagrant-cachier
vagrant plugin install vagrant-vbguest
vagrant plugin install vagrant-bindfs

# Add entries to /etc/sudoers to allow Vagrant NFS usage without password
append_if_missing "Cmnd_Alias VAGRANT_EXPORTS_ADD = /usr/bin/tee -a /etc/exports" /etc/sudoers
append_if_missing "Cmnd_Alias VAGRANT_NFSD = /sbin/nfsd restart" /etc/sudoers
append_if_missing "Cmnd_Alias VAGRANT_EXPORTS_REMOVE = /usr/bin/sed -E -e /*/ d -ibak /etc/exports" /etc/sudoers
append_if_missing "%admin ALL=(root) NOPASSWD: VAGRANT_EXPORTS_ADD, VAGRANT_NFSD, VAGRANT_EXPORTS_REMOVE" /etc/sudoers

# install rbenv plugins
git_install git://github.com/tpope/rbenv-ctags.git ~/.rbenv/plugins/rbenv-ctags
git_install https://github.com/sstephenson/rbenv-default-gems.git ~/.rbenv/plugins/rbenv-default-gems
git_install https://github.com/rkh/rbenv-update.git ~/.rbenv/plugins/rbenv-update
git_install git://github.com/tpope/rbenv-readline.git ~/.rbenv/plugins/rbenv-readline
if [[ -e ~/.rbenv/default-gems ]]; then
  echo 'awesome_print' > ~/.rbenv/default-gems
  echo 'gem-browse' >> ~/.rbenv/default-gems
  echo 'gem-ctags' >> ~/.rbenv/default-gems
  echo 'git-up' >> ~/.rbenv/default-gems
  echo 'foreman' >> ~/.rbenv/default-gems
  echo 'html2haml' >> ~/.rbenv/default-gems
  echo 'middleman' >> ~/.rbenv/default-gems
  echo 'pry' >> ~/.rbenv/default-gems
  echo 'rubocop' >> ~/.rbenv/default-gems
  echo 'cocoapods' >> ~/.rbenv/default-gems
  echo 'terminal-notifier' >> ~/.rbenv/default-gems
fi

# TODO: install Jaguar Gemfury source and Jag gems automatically,
# but we can't do this with a publicly viewable repo.
# Implement this when moving to Ansible and use ansible-vault for
# protecting the repo's credentials

# Configure DNSMasq for *.test TLD
sudo mkdir -p /usr/local/etc
echo "address=/.test/127.0.0.1" > /usr/local/etc/dnsmasq.conf
sudo cp -fv /usr/local/opt/dnsmasq/*.plist /Library/LaunchDaemons
sudo launchctl load /Library/LaunchDaemons/homebrew.mxcl.dnsmasq.plist
sudo mkdir -p /etc/resolver
sudo sh -c 'echo "nameserver 127.0.0.1" > /etc/resolver/test'

output ""
output "Build complete! Thank you for using START ME UP"
