alias gitdir="cd /home/$USER/Documents/Git/"
alias vmaas="cd /home/$USER/Documents/Git/VMaaS/"

alias gl="git log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset'"

# go through all folders in $gitdir and fetch + status
function gitdircheck {
  returndir=`pwd`
  gitdir;
  for dir in */; do
    cd $dir;
    printf '%48s\n' | tr ' ' -;
    echo $dir;
    git fetch;
    git status;
    cd ..;
  done
  cd $returndir
}

function gitdirpull {
  returndir=`pwd`
  gitdir;
  for dir in */; do
    cd $dir;
    printf '%48s\n' | tr ' ' -;
    echo $dir;
    git pull;
    cd ..;
  done
  cd $returndir
}

function gitdirclean {
  returndir=`pwd`
  gitdir;
  for dir in */; do
    cd $dir;
    printf '%48s\n' | tr ' ' -;
    echo $dir;
    git clean -xi;
    cd ..;
  done
  cd $returndir
}
