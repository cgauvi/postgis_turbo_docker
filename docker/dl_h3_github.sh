#! /bin/bash

if [ ! -d ./h3c ]; then
    git clone https://github.com/uber/h3.git h3c
elif [  -z "$(ls -A ./h3c)" ]; then
    echo 'h3 repo exists, but is empty - recloning fresh.. '
    rm -rf ./h3c
    git clone https://github.com/uber/h3.git h3c
else
    echo 'h3 cloned src code already exists'
fi