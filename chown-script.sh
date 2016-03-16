#!/bin/bash 

for dir in `ls ~`
do
  if [[ ! -w $dir ]]; then
    sudo chown -R dev:dev $dir
  fi
done
