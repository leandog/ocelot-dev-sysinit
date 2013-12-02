#!/usr/bin/env bash

if ! [[ -d "/Applications/Xcode.app" ]]
then
  echo -e "\nIt looks like you don't have Xcode installed. You need Xcode 4.3 or higher with the Command Line Tools installed to be able to continue"
  exit
else
  echo -e "\n**** You have `xcodebuild -version` installed"
fi

result=`which gcc`

if [[ -z "$result" ]]
then
  echo -e "\n**** It looks like the Command Line Tools aren't installed. If you have Xcode 4.3 or higher installed, launch Xcode, open the preferences, click on Downloads, and be sure to install the Command Line Tools!\n\nAfter you have installed the Command Line Tools, rerun this script."
  exit
fi

result=`which brew 2>&1`

if [[ -z "$result" ]]
then
  echo -e "\n**** HomeBrew is not installed"
  echo "**** Installing HomeBrew"
  ruby <(curl -fsSkL raw.github.com/mxcl/homebrew/go)
  echo "export PATH=/usr/local/bin:/usr/local/sbin:$PATH" >> ~/.bashrc
  source ~/.bashrc
  brew tap homebrew/dupes
else
  echo -e "\n**** HomeBrew is already installed: `echo $result`"
  echo "**** Upgrading HomeBrew to the latest build"
  brew update
  brew tap homebrew/dupes
fi

result=`brew list`

if ! [[ $result =~ ack ]]
then
  echo -e "\n**** Installing Ack, this will help with Vim later"
  brew install ack
fi

if ! [[ $result =~ the_silver_searcher ]]
then
  echo -e "\n**** Installing the_silver_searcher, this will help with Vim later"
  brew install the_silver_searcher
fi

othergit=`which git`

if ! [[ $result =~ git || -z "$othergit" ]]
then
  echo -e "\n**** Installing git, you'll need this for source control"
  brew install git

  cat >> ~/.gitconfig <<EOL
[color]
  diff = auto
  status = auto
  branch = auto
  interactive = auto
  ui = auto
[gc]
  auto = 1
[merge]
  summary = true
[alias]
  co = checkout
  ci = commit -v
  st = status
  cp = cherry-pick -x
  rb = rebase
  pr = pull --rebase
  br = branch
  b = branch -v
  r = remote -v
  t = tag -l
  put = push origin HEAD
  unstage = reset HEAD
  uncommit = reset --soft HEAD^
  recommit = commit -C head --amend
  d = diff
  c = commit -v
  s = status
  dc = diff --cached
  pr = pull --rebase
  ar = add -A
EOL

  echo " "
  read -p "What is your first & last name to be used in Git commits (ie. John Doe) : "
  echo
  git config --global user.name "$REPLY"

  echo " "
  read -p "What is your email to be used in Git commits (ie. john.doe@leandog.com) : "
  echo
  git config --global user.email "$REPLY"
fi

if ! [[ $result =~ vim ]]; then
  echo -e "\n**** Installing vim"
  brew install vim

  source ~/.bashrc
  echo -e "\n**** Installing Menlo Regular for Powerline font which allows unicode characters to display"
  curl -so /Library/Fonts/Menlo\ Regular\ For\ Powerline.ttf https://raw.github.com/Lokaltog/powerline-fonts/master/Menlo/Menlo%20Regular%20for%20Powerline.ttf

  echo -e "**** Currently will overwrite your .vimrc"
  git clone https://github.com/leandog/vim-config.git ~/.vim
  ~/.vim/postinstall.sh
fi

result=`which rvm`

if [[ -z "$result" ]]
then
  echo -e "\n**** RVM Not installed"
  echo "**** Installing RVM"
  touch ~/.bashrc
  curl -L https://get.rvm.io | bash -s stable
  curl -so ~/.rvmsh https://raw.github.com/leandog/ocelot-dev-sysinit/master/rvm.sh
  cat >> ~/.bashrc <<EOL
source ~/.rvmsh
EOL

  echo -e "\n**** Installing a default .gemrc"
  echo "gem: --no-ri --no-rdoc" >> ~/.gemrc
  echo -e "\n**** Installing a default .rvmrc"
  cat > ~/.rvmrc <<EOL
rvm_ps1=1
rvm_path="${HOME}/.rvm"
rvm_pretty_print_flag=1
rvm_gemset_create_on_use_flag=1
EOL

  source ~/.bashrc
  rvm reload
else
  echo -e "\n**** RVM installed: `echo $result`"
  echo "**** Upgrading RVM to the latest build"
  rvm get stable
  rvm reload
fi

if ! [[ -f ~/.bash_profile ]]
then

  echo -e "\n**** Looks like you don't have a .bash_profile, let's make one!"
  touch ~/.bash_profile

  cat > ~/.bash_profile <<EOL
if [ -f ~/.bashrc ] && [ "${SHELL##*/}" == "bash" ]
then
  . ~/.bashrc
fi
EOL

fi

echo -e "\n**** Installing Apple's older GCC 4.2 binaries & other required libs from HomeBrew to be able to build Ruby prior to 1.9.3 and most gems"
rvm requirements

echo -e "\n**** Making your terminal actually use colors!"
cat > ~/.bashrc <<EOL
export CLICOLOR=1
export LSCOLORS=GxFxCxDxBxegedabagaced
EOL

