#!/bin/bash

sudo setenforce 0
virsh -c qemu:///system start winvm
flatpak run com.github.debauchee.barrier
