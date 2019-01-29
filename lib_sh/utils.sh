#!/usr/bin/env bash

# source ./utils.sh

function question() {
    echo -en "\n$COL_MAGENTA ¿$COL_RESET" $1 " "
    read -rp "" ret
    eval "$2=\$ret"
}

function download() {
    running "downloading $1";filler
    http="${2:0:4}"
    if [[ $http = "http" ]]; then
        curl -#LO "$2" --retry 999 --retry-max-time 0 -C -
    else
        gdrive download "$2"
    fi
    if [[ $? != 0 ]]; then
        error "failed to download $1!"
    fi
    ok
}

function download_app() {
    appname=$1
    link=$2
    softpath=`whichapp "$appname" > /dev/null 2>&1`
    if [ $? == 1 ]; then
      question "$appname is not installed. Do you want to download? [Y|n]" response
      if [[ -z "$response" ]]; then response='Y'; fi
    else
      question "$appname is already installed. Do you want to download again? [y|N]" response
      if [[ -z "$response" ]]; then response='N'; fi
    fi

    if [[ $response =~ ^(yes|y|Y) ]]; then
      running "Downloading $appname to ~/Downloads"; filler
      pushd ~/Downloads > /dev/null 2>&1
      download "$appname" "$link"
      popd > /dev/null 2>&1
    fi
}

function symlinkifne {
    echo -en " $1"

    if [[ -e $1 ]]; then
        # file exists
        if [[ -L $1 ]]; then
            # it's already a simlink (could have come from this project)
            echo -en ' simlink exists, skipping ';ok
            return
        fi
        # backup file does not exist yet
        if [[ ! -e ~/.dotfiles_backup/$1 ]];then
            mv $1 ~/.dotfiles_backup/
            echo -en ' backed up saved;';
        fi
    fi
    # create the link
    ln -s ~/.dotfiles/$1 $1
    echo -en ' linked ';ok
}

