#!/usr/bin/env bash

bash ./bootstrap.sh

mkdir -p /opt/libpostal_data/libpostal
DATA_DIR=/opt/libpostal_data

bash ./configure --disable-data-download  --datadir=$DATA_DIR
make -j4
make install
ldconfig
 

