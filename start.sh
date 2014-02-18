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

################
# START ME UP! #
################

output ""
output "START ME UP"
output ""

output "Do you wish to run the entire script automatically?"
output "(If 'Y', entire script will install without ask prompts)"
output "(Choose 'Y' for fresh installs, 'N' if running on a non-fresh system)"
read -p "[y/N] " auto_confirm
# TODO: guard against invalid values

# If Linux, make sure this is a Ubuntu or Debian we know
if [[ $OS == 'linux' ]]; then
  version_check
fi

if [[ $OS == 'linux' ]]; then
  output "Enabling multiarch"
  sudo dpkg --add-architecture i386
fi

if [[ $OS == 'mac' ]]; then
  output "Adding shell config files to HOME"
  touch ~/.bash_profile
  touch ~/.bashrc
  touch ~/.zshrc
fi

if [[ $OS == 'linux' ]]; then
  ask_prompt "Enable universe/multiverse repos?" && (
    output "Enabling universe/multiverse repos"
    add_apt_list "deb http://us.archive.ubuntu.com/ubuntu/ $(distro_name) universe multiverse" universe
    add_apt_list "deb http://us.archive.ubuntu.com/ubuntu/ $(distro_name)-updates universe multiverse" universe
  )
fi

if [[ $OS == 'linux' ]]; then
  output "Updating package cache, upgrading installed packages"
  apt_update
  apt_upgrade
fi

if [[ $OS == 'mac' ]]; then
  ask_prompt "Install Xcode?" && (
    output "Installing Xcode"
    output ""
    output "Opening Xcode page in App Store in 5 seconds."
    output "Once Xcode is installed, return here and continue."
    sleep 5
    open -n 'macappstore://itunes.apple.com/us/app/xcode/id497799835'
    sleep 10
    read -p "Press Enter once you've completed installing Xcode..."
    output "Installing Xcode Command Line Tools"
    bash <(curl -s https://raw.github.com/timsutton/osx-vm-templates/master/scripts/xcode-cli-tools.sh)
    output ""
  )
fi

if [[ $OS == 'mac' ]]; then
  ask_prompt "Install Homebrew? (must install if not already installed)" && (
    output "Installing Homebrew"
    ruby -e "$(curl -fsSL https://raw.github.com/Homebrew/homebrew/go/install)"
    brew install curl-ca-bundle
    append_if_missing 'SSL_CERT_FILE=/usr/local/opt/curl-ca-bundle/share/ca-bundle.crt' ~/.bashrc
    append_if_missing 'SSL_CERT_FILE=/usr/local/opt/curl-ca-bundle/share/ca-bundle.crt' ~/.zshrc
  )
fi

if [[ $OS == 'mac' ]]; then
  ask_prompt "Install Homebrew Cask? (Homebrew addon for GUI apps - must install if not already installed)" && (
    output "Installing Cask, Homebrew addon for GUI apps"
    brew tap phinze/homebrew-cask
    brew_install brew-cask
    brew tap caskroom/versions
    export HOMEBREW_CASK_OPTS="--appdir=/Applications"
    append_if_missing 'export HOMEBREW_CASK_OPTS="--appdir=/Applications"' ~/.bashrc
    append_if_missing 'export HOMEBREW_CASK_OPTS="--appdir=/Applications"' ~/.zshrc
  )
fi

if [[ $OS == 'mac' ]]; then
  ask_prompt "Install bash? (bash included with OS X is out of date)" && (
    output "Installing bash"
    brew_install bash
    if ! grep -Fxq /usr/local/bin/bash /etc/shells; then
      echo "/usr/local/bin/bash" | sudo tee -a /etc/shells
    fi
    ask_prompt "Do you want to set bash as your default shell?" && (
      chsh -s /usr/local/bin/bash
    )
  )
fi

ask_prompt "Install zsh?" && (
  output "Installing zsh"
  if [[ $OS == 'linux' ]]; then
    apt_install zsh
    ask_prompt "Do you want to set zsh as your default shell?" && (
      chsh -s /usr/bin/zsh
    )
  elif [[ $OS == 'mac' ]]; then
    brew_install zsh reattach-to-user-namespace
    if test -f /etc/zshenv; then
      sudo mv /etc/zshenv /etc/zprofile
    fi
    if ! grep -Fxq /usr/local/bin/zsh /etc/shells; then
      echo "/usr/local/bin/zsh" | sudo tee -a /etc/shells
    fi
    ask_prompt "Do you want to set zsh as your default shell?" && (
      chsh -s /usr/local/bin/zsh
    )
  fi
)

ask_prompt "Install development packages?" && (
  output "Installing development packages"
  if [[ $OS == 'linux' ]]; then
    apt_install build-essential bison openssl libreadline6 libreadline6-dev zlib1g zlib1g-dev libssl-dev libyaml-dev libxml2-dev libxslt-dev autoconf libc6-dev automake cmake libc6-dev libmysql++-dev libsqlite3-dev make phantomjs
  elif [[ $OS == 'mac' ]]; then
    brew_install gdbm libffi libksba libyaml phantomjs qt
  fi
)

ask_prompt "Install version control systems?" && (
  output "Installing version control systems"
  install git subversion
)

ask_prompt "Install node.js? (Used for JSHint and IE VMs controller)" && (
  output "Installing node.js"
  if [[ $OS == 'linux' ]]; then
    apt_install nodejs
  elif [[ $OS == 'mac' ]]; then
    brew_install node
  fi
)

ask_prompt "Install tmux?" && (
  output "Installing tmux"
  install tmux
)

ask_prompt "Install htop? (better 'top' command)" && (
  output "Installing htop"
  if [[ $OS == 'linux' ]]; then
    apt_install htop
  elif [[ $OS == 'mac' ]]; then
    brew_install htop-osx
  fi
)

ask_prompt "Install PgAdmin3? (PostgreSQL GUI client)" && (
  output "Installing PgAdmin3"
  if [[ $OS == 'linux' ]]; then
    apt_install pgadmin3
  elif [[ $OS == 'mac' ]]; then
    cask_install pgadmin3
  fi
)

ask_prompt "Install latest Vim build? (Best text editor evar!)" && (
  output "Installing vim (latest)"
  if [[ $OS == 'linux' ]]; then
    add_apt ppa:dgadomski/vim-daily
    apt_install vim vim-gnome
  elif [[ $OS == 'mac' ]]; then
    brew_install macvim --HEAD --override-system-vim --with-cscope --with-lua
  fi
)

# TODO: Add option for Sublime Text 3
ask_prompt "Install Sublime Text 2?" && (
  output "Installing Sublime Text"
  if [[ $OS == 'linux' ]]; then
    add_apt ppa:webupd8team/sublime-text-2
    apt_update
    apt_install sublime-text
  elif [[ $OS == 'mac' ]]; then
    cask_install sublime-text
  fi
)

ask_prompt "Install ctags?" && (
  output "Installing ctags"
  if [[ $OS == 'linux' ]]; then
    apt_install exuberant-ctags
  elif [[ $OS == 'mac' ]]; then
    brew_install ctags
  fi
)

ask_prompt "Install ag? (grep-like code searching)" && (
  output "Installing ag (aka The Silver Searcher)"
  if [[ $OS == 'linux' ]]; then
    apt_install silversearcher-ag
  elif [[ $OS == 'mac' ]]; then
    brew_install the_silver_searcher
  fi
)

ask_prompt "Install keyboard-based launcher? (Synapse in Linux, Alfred in OS X)" && (
  if [[ $OS == 'linux' ]]; then
    output "Installing Synapse"
    apt_install synapse
  elif [[ $OS == 'mac' ]]; then
    output "Installing Alfred"
    cask_install alfred
  fi
)

ask_prompt "Install Google Chrome?" && (
  output "Installing Google Chrome"
  if [[ $OS == 'linux' ]]; then
    apt_key https://dl-ssl.google.com/linux/linux_signing_key.pub
    add_apt_list "deb http://dl.google.com/linux/chrome/deb/ stable main" google-chrome
    apt_update
    apt_install google-chrome-stable
  elif [[ $OS == 'mac' ]]; then
    cask_install google-chrome
  fi
)

ask_prompt "Install pre-release Chrome for testing?" && (
  if [[ $OS == 'linux' ]]; then
    output "Installing Chromium (Dev channel)"
    add_apt ppa:saiarcot895/chromium-dev
    apt_update
    apt_install chromium-browser
  elif [[ $OS == 'mac' ]]; then
    output "Installing Google Chrome Canary"
    cask_install google-chrome-canary
  fi
)

ask_prompt "Install Firefox?" && (
  output "Installing Firefox"
  if [[ $OS == 'linux' ]]; then
    apt_install firefox
  elif [[ $OS == 'mac' ]]; then
    cask_install firefox
  fi
)

ask_prompt "Install pre-release Firefox for testing?" && (
  if [[ $OS == 'linux' ]]; then
    output "Install Firefox Nightly"
    add_apt ppa:ubuntu-mozilla-daily/ppa
    apt_update
    apt_install firefox-trunk
  elif [[ $OS == 'mac' ]]; then
    output "Install Firefox Aurora"
    cask_install firefox-aurora
  fi
)

ask_prompt "Install rbenv? (Ruby version manager)" && (
  output "Installing rbenv and plugins"
  git_install https://github.com/sstephenson/rbenv.git ~/.rbenv
  git_install https://github.com/sstephenson/ruby-build.git ~/.rbenv/plugins/ruby-build
  git_install git://github.com/tpope/rbenv-ctags.git ~/.rbenv/plugins/rbenv-ctags
  git_install https://github.com/sstephenson/rbenv-default-gems.git ~/.rbenv/plugins/rbenv-default-gems
  git_install https://github.com/rkh/rbenv-update.git ~/.rbenv/plugins/rbenv-update
  if [[ $OS == 'mac' ]]; then
    git_install git://github.com/tpope/rbenv-readline.git ~/.rbenv/plugins/rbenv-readline
  fi
  ask_prompt "Add rbenv to your bash/zsh config? (Choose yes only if this is a fresh install of rbenv, not an update)" && (
    if [[ $OS == 'mac' ]]; then
      append_if_missing 'export PATH="$HOME/.rbenv/bin:$PATH"' ~/.bash_profile
      append_if_missing 'eval "$(rbenv init -)"' ~/.bash_profile
    elif [[ $OS == 'linux' ]]; then
      append_if_missing 'export PATH="$HOME/.rbenv/bin:$PATH"' ~/.bashrc
      append_if_missing 'eval "$(rbenv init -)"' ~/.bashrc
    fi
    append_if_missing 'export PATH="$HOME/.rbenv/bin:$PATH"' ~/.zshrc
    append_if_missing 'eval "$(rbenv init -)"' ~/.zshrc
    # Default gems
    echo 'bundler' > ~/.rbenv/default-gems
    echo 'gem-ctags' >> ~/.rbenv/default-gems
    echo 'gem-browse' >> ~/.rbenv/default-gems
    echo 'git-up' >> ~/.rbenv/default-gems
    echo 'foreman' >> ~/.rbenv/default-gems
    echo 'middleman' >> ~/.rbenv/default-gems
    echo 'rubocop' >> ~/.rbenv/default-gems
    echo 'paint' >> ~/.rbenv/default-gems
    echo 'pry' >> ~/.rbenv/default-gems
    echo 'pry-remote' >> ~/.rbenv/default-gems
    echo 'pry-coolline' >> ~/.rbenv/default-gems
    echo 'awesome_print' >> ~/.rbenv/default-gems
    echo 'coderay' >> ~/.rbenv/default-gems
    if [[ $OS == 'mac' ]]; then
      echo 'cocoapods' >> ~/.rbenv/default-gems
      echo 'lunchy' >> ~/.rbenv/default-gems
      echo 'terminal-notifier' >> ~/.rbenv/default-gems
    fi
  )
)

ask_prompt "Install pyenv? (fork of rbenv for managing Python installs)" && (
  output "Installing pyenv and plugins"
  git_install git://github.com/yyuu/pyenv.git ~/.pyenv
  git_install git://github.com/yyuu/pyenv-virtualenv.git ~/.pyenv/plugins/pyenv-virtualenv
  ask_prompt "Add pyenv to your bash/zsh config? (Choose yes only if this is a fresh install of pyenv, not an update)" && (
    if [[ $OS == 'mac' ]]; then
      append_if_missing 'export PATH="$HOME/.pyenv/bin:$PATH"' ~/.bash_profile
      append_if_missing 'eval "$(pyenv init -)"' ~/.bash_profile
    elif [[ $OS == 'linux' ]]; then
      append_if_missing 'export PATH="$HOME/.pyenv/bin:$PATH"' ~/.bashrc
      append_if_missing 'eval "$(pyenv init -)"' ~/.bashrc
    fi
    append_if_missing 'export PATH="$HOME/.pyenv/bin:$PATH"' ~/.zshrc
    append_if_missing 'eval "$(pyenv init -)"' ~/.zshrc
  )
)

ask_prompt "Install Virtualbox and Vagrant? (required for running dev environments)" && (
  output "Installing Virtualbox and Vagrant"
  if [[ $OS == 'linux' ]]; then
    apt_key http://download.virtualbox.org/virtualbox/debian/oracle_vbox.asc
    add_apt_list "deb http://download.virtualbox.org/virtualbox/debian $(distro_name) contrib" virtualbox
    apt_update
    apt_install virtualbox-4.3
    # Vagrant, y u no apt repo?
    deb_install https://dl.bintray.com/mitchellh/vagrant/vagrant_1.4.3_x86_64.deb
  elif [[ $OS == 'mac' ]]; then
    cask_install virtualbox
    cask_install vagrant
    nfsd checkexports
  fi
  vagrant plugin install dotenv
  vagrant plugin install vagrant-digitalocean
  vagrant plugin install vagrant-notify
  vagrant plugin install vagrant-vbguest
  vagrant plugin install vagrant-vbox-snapshot
)

if [[ $OS == 'linux' ]]; then
  ask_prompt "Install good looking non-free fonts?" && (
    output "Font packages"
    apt_install ttf-mscorefonts-installer fonts-inconsolata fonts-opensymbol mathematica-fonts
    output "Installing Typecatcher for access to Google Webfonts"
    add_apt ppa:andrewsomething/typecatcher
    apt_update
    apt_install typecatcher
  )
fi

if [[ $OS == 'mac' ]]; then
  ask_prompt "Install iterm2? (better terminal emulator)" && (
    output "Installing iterm2"
    cask_install iterm2-beta
  )
fi

ask_prompt "Install HipChat?" && (
  output "Installing HipChat"
  if [[ $OS == 'linux' ]]; then
    apt_key https://www.hipchat.com/keys/hipchat-linux.key
    add_apt_list "deb http://downloads.hipchat.com/linux/apt stable main" atlassian-hipchat
    apt_update
    apt_install hipchat
  elif [[ $OS == 'mac' ]]; then
    cask_install hipchat
  fi
)

ask_prompt "Install Dropbox?" && (
  output "Installing Dropbox"
  if [[ $OS == 'linux' ]]; then
    if ! command -v dropbox > /dev/null; then
      deb_install https://www.dropbox.com/download?dl=packages/ubuntu/dropbox_1.6.0_amd64.deb
    fi
  elif [[ $OS == 'mac' ]]; then
    cask_install dropbox
  fi
)

if [[ $OS == 'mac' ]]; then
  ask_prompt "Install Google Drive?" && (
    output "Installing Google Drive"
    cask_install google-drive
  )
fi

if [[ $OS == 'mac' ]]; then
  ask_prompt "Install Harvest time tracking widget?" && (
    output "Installing Harvest time tracking widget"
    cask_install harvest
  )
fi

ask_prompt "Install Skype?" && (
  output "Installing Skype"
  if [[ $OS == 'linux' ]]; then
    add_apt_list "deb http://archive.canonical.com/ $(distro_name) partner"
    apt_update
    apt_install skype
  elif [[ $OS == 'mac' ]]; then
    cask_install skype
  fi
)

if [[ $OS == 'mac' ]]; then
  ask_prompt "Install Screenhero?" && (
    output "Installing Screenhero"
    cask_install screenhero
  )
fi

if [[ $OS == 'mac' ]]; then
  ask_prompt "Install Mou? (Markdown editor)" && (
    output "Installing Mou markdown editor"
    cask_install mou
  )
fi

ask_prompt "Install JSHint? (JavaScript code linter)" && (
  output "Installing JSHint"
  sudo npm install -g jshint
)

ask_prompt "Install IE virtual machines? (ievms)" && (
  output "Installing IE virtual machines (ievms) and control tool (iectrl)"
  curl -s https://raw.github.com/xdissent/ievms/master/ievms.sh | bash
  sudo npm install -g iectrl
)

ask_prompt "Configure Git?" && (
  output ".gitconfig setup"
  read -p "Enter your FULL name (first and last) and press Enter: " git_name
  git config --global user.name "$git_name"
  read -p "Enter your Jaguar email address and press Enter: " git_email
  git config --global user.email $git_email
)

output ""
output "All done! Thanks for using START ME UP"

# vim: set ft=bash
