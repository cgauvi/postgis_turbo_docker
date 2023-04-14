#!/usr/bin/env bash

bash ./bootstrap.sh
mkdir -p /opt/libpostal_data
bash ./configure --datadir=/opt/libpostal_data
make -j4
make install
ldconfig