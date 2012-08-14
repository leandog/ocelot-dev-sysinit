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
  `curl -so ~/.vim/update_bundles https://raw.github.com/leandog/
fi

result=`which rvm`

if [$result -eq ""]
then
  echo "RVM Not installed"
  echo "Installing RVM"
  `curl -L https://get.rvm.io | bash -s stable`
  `rvm reload`
  `echo '[[ -s "$HOME/.rvm/scripts/rvm" ]] && . "$HOME/.rvm/scripts/rvm"' >> ~/.bashrc`

else
  echo "RVM installed: `echo $result`"
  echo "Upgrading RVM to the latest build"
  `rvm get head`
  `rvm reload`
fi


