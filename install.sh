#!/usr/bin/env bash

result=`which gcc`

if [$result -eq ""]
then
  echo "It looks like you don't have XCode 4.4 or higher installed... or, the commandline tools installed at minimum."
  echo "If you have XCode 4.3 or higher installed, launch XCode, open the preferences, click on Downloads, and be sure to install the Commandline Tools!"
  echo " "
  echo "If you don't have XCode installed and don't want to install it, then you need to get the separate Commandline Tools installer from Apple."
  echo "The Commandline Tools are available from:  http://developer.apple.com/downloads"
  echo "You will need an Apple ID in order to get the download."
  echo "After you have installed either XCode or the Commandline Tools, rerun this script."
  exit
fi

result=`ls -la ~/.bash_profile`

if [[ $result =~ No\ such\ file ]]
then
  echo "Looks like you don't have a .bash_profile, let's make one!"
  `touch ~/.bash_profile`
  `cat <<EOF >> ~/.bash_profile
  if [ -f ~/.bashrc ] && [ "${SHELL##*/}" == "bash" ]
  then
    . ~/.bashrc
  fi
  EOF`
fi

result=`which brew`

if [$result -eq ""]
then
  echo "HomeBrew is not installed"
  echo "Installing HomeBrew"
  `ruby <(curl -fsSkL raw.github.com/mxcl/homebrew/go)`
  `brew tap homebrew/dupes`
else
  echo "HomeBrew is already installed: `echo $result`"
  echo "Upgrading HomeBrew to the latest build"
  `brew update`
  `brew tap homebrew/dupes`
fi

result=`brew list`

if ! [[ $result =~ apple-gcc42 ]]
then
  echo "Installing Apple's older GCC 4.2 binaries from HomeBrew"
  `brew install apple-gcc42`
  echo "Symlinking GCC in"
  `sudo ln -s /usr/local/bin/gcc-4.2 /usr/bin/gcc-4.2`
fi

if ! [[ $result =~ ack ]]
then
  echo "Installing Ack, this will help with Vim later"
  `brew install ack`
fi

if ! [[ $result =~ git ]]
then
  echo "Installing git"
  `brew install git`
  `cat <<EOF >> ~/.gitconfig
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
  EOF`

  while true; do
    echo "What is your name to be used for Git?"
    read -p "This is your first & last name to be used in Git commits (ie. John Doe) :" yn
    git config --global user.name "$yn"
  done

  while true; do
    echo "What is your email to be used for Git?"
    read -p "This is to be used in Git commits (ie. john.doe@leandog.com) :" yn
    git config --global user.email "$yn"
  done
fi

if ! [[ $result =~ macvim ]]
then
  echo "Installing MacVim since it is much newer than the Vim installed in OS X"
  `brew install macvim`
  echo "Adding vim override to local .bashrc"
  `cat <<EOF >> ~/.bashrc
  vim() {
    /Applications/MacVim.app/Contents/MacOS/Vim $*
  }
  EOF`
  `source ~/.bashrc`
  echo "Install Pathogen plugin for Vim"
  `mkdir -p ~/.vim/autoload ~/.vim/bundle`
  `curl -so ~/.vim/autoload/pathogen.vim https://raw.github.com/tpope/vim-pathogen/master/autoload/pathogen.vim`
  `curl -so ~/.vim/update_bundles https://raw.github.com/leandog/ocelot-dev-sysinit/master/update_bundles`
  vimrccheck=`ls -la ~/.vimrc`

  if [[ $vimrccheck =~ No\ such\ file ]]
  then
    echo "Installing a default .vimrc"
    `curl -so ~/.vimrc https://raw.github.com/leandog/ocelot-dev-sysinit/master/.vimrc`
  else
    echo "You appear to already have a .vimrc, here's what we would've put in there..."
    echo `curl https://raw.github.com/leandog/ocelot-dev-sysinit/master/.vimrc`
  fi
fi

result=`which rvm`

if [$result -eq ""]
then
  echo "RVM Not installed"
  echo "Installing RVM"
  `curl -L https://get.rvm.io | bash -s stable`
  `rvm reload`
  `curl -so ~/.rvmsh https://raw.github.com/gist/898797/ead7ee759f8a1445db781b5b15bda49b418311f4//etc/profile.d/rvm.sh`
  `echo 'source ~/.rvmsh' >> ~/.bashrc`
  `echo '[[ -s "$HOME/.rvm/scripts/rvm" ]] && . "$HOME/.rvm/scripts/rvm"' >> ~/.bashrc`
  echo "Installing a default .gemrc"
  `curl -so ~/.gemrc https://raw.github.com/leandog/ocelot-dev-sysinit/master/.gemrc`
  echo "Installing a default .rvmrc"
  `echo "rvm_ps1=1" >> ~/.rvmrc`
  `echo 'rvm_path="`echo $HOME`/.rvm"' >> ~/.rvmrc`
  `echo "rvm_pretty_print_flag=1" >> ~/.rvmrc`
  `echo "rvm_gemset_create_on_use_flag=1" >> ~/.rvmrc`
else
  echo "RVM installed: `echo $result`"
  echo "Upgrading RVM to the latest build"
  `rvm get head`
  `rvm reload`
fi


