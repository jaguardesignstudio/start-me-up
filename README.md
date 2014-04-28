# Start Me Up

![](http://i.imgur.com/ubdJQL7.jpg)

Because bootstrapping a new development machine can make a grown man (or woman) cry.

More than a little bit inspired by Thoughtbot's [Laptop](https://github.com/thoughtbot/laptop/) scripts, but opinionated for our use.

## Notes

This script works with Mac OS X 10.9+ and Ubuntu 12.04+ x64

## Instructions

Run the following command from the command line:

    bash <(curl -s https://raw.githubusercontent.com/jaguardesign/start-me-up/master/start.sh)

## What It Installs

### Prerequisites
- [OSX] Homebrew
- [OSX] Homebrew Casks (Homebrew addon for GUI apps)
- [OSX] Xcode + Command Line Tools
- [Ubuntu] Multiarch (i386)
- [Ubuntu] Universe/Multiverse repos
- Development packages / library dependencies

### Development Environment
- rbenv (Ruby version management)
    - Plugins: ruby-build, rbenv-ctags, rbenv-default-gems, rbenv-update
- pyenv (Python version management)
    - Plugins: pyenv-virtualenv
- Virtualbox
- Vagrant
    - Plugins: dotenv, vagrant-digitalocean, vagrant-vbguest, vagrant-snapshot
- Microsoft's IE App Compatibility Virtual Machines ([ievms](https://github.com/xdissent/ievms))
    - [iectrl](https://github.com/xdissent/iectrl) for rearming VMs
- Version control clients (Git, Subversion)
- Git GUI clients
    - [OSX] GitX, SourceTree
    - [Ubuntu] gitg
- vim (latest builds)
- Sublime Text 2

### Browsers
- Chrome
- Chrome pre-release build for testing
    - [OSX] Canary
    - [Ubuntu] Chromium dev channel
- Firefox
- Firefox pre-release build for testing
    - [OSX] Aurora
    - [Ubuntu] Nightly build

### Collaboration
- HipChat
- Dropbox
- Skype
- [OSX] Google Drive

### Handy Tools
- Desktop search tools
    - [OSX] Alfred
    - [Ubuntu] Synapse
- [OSX] iTerm2
- [OSX] Harvest
- [Ubuntu] Fonts not included in base Ubuntu install

### Delicious UNIX
- [OSX] Up-to-date bash
- zsh
- tmux
- ctags
- ag
- htop

## My machine is already up and running, I have some of this!
At the start of the script, you'll have the opportunity to choose to either run the entire script, or to selectively install the pieces you need.
