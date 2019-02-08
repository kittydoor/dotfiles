# TODO: Maybe use awk with the output of type -p st urxvt ...
if type -p st > /dev/null; then
  export TERMINAL="st"
elif type -p urxvt > /dev/null; then
  export TERMINAL="urxvt"
fi

export EDITOR="vim"
export BROWSER="firefox-developer-edition"
export FILE="ranger"

# less always intepret control chars
export LESS=-R
