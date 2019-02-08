#!/bin/sh

export TERMINAL="$(basename "$(type -p st-kitty st urxvt)")"
export EDITOR="vim"
export BROWSER="firefox-developer-edition"
export FILE="ranger"
export READER="zathura"

# less always intepret control chars
export LESS=-R
