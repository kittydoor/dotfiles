#!/bin/bash

awk '/^md/ {printf "%s: ", $1}; /blocks/ {print $NF}' </proc/mdstat
