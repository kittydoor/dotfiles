#!/bin/bash
if ! [ -d /sys/class/backlight/intel_backlight ]; then
  exit 1
fi;

log="brightness.sh"
if [[ $1 == "inc" ]]; then
  log+=" incrementing by"
elif [[ $1 == "dec" ]]; then
  log+=" decrementing by"
else
  log="Error. Incorrect arguments."
  exit 2;
fi;

if [[ $2 =~ ^[1-9][0-9]?$ ]]; then
  log+=" $2%\n"
else
  exit 2;
fi;

log+="max\tcur\tstep\tchange\tnew\tfinal\n"

current_brightness=$(cat /sys/class/backlight/intel_backlight/brightness);
log+="$current_brightness\t"

max_brightness=$(cat /sys/class/backlight/intel_backlight/max_brightness)
log+="$max_brightness\t"

let brightness_step=$max_brightness/100;
log+="$brightness_step\t"

let change=$2*$brightness_step;
log+="$change\t"

if [[ $1 == "inc" ]]; then
  let new_brightness=$current_brightness+$change;
  log+="$new_brightness\t"
  if [[ $new_brightness -gt $max_brightness ]]; then
    echo $max_brightness > /sys/class/backlight/intel_backlight/brightness;
  else
    echo $new_brightness > /sys/class/backlight/intel_backlight/brightness;
  fi;
elif [[ $1 == "dec" ]]; then
  let new_brightness=$current_brightness-$change;
  log+="$new_brightness\t"
  if [[ $new_brightness -lt 0 ]]; then
    echo 0 > /sys/class/backlight/intel_backlight/brightness;
  else
    echo $new_brightness > /sys/class/backlight/intel_backlight/brightness;
  fi;
fi;

final_brightness=$(cat /sys/class/backlight/intel_backlight/brightness);
log+="$final_brightness";

echo -e $log;
