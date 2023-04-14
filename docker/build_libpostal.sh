#!/usr/bin/env bash

bash ./bootstrap.sh

mkdir -p /opt/libpostal_data/libpostal
DATA_DIR=/opt/libpostal_data

bash ./configure --disable-data-download  --datadir=$DATA_DIR
make -j4
make install
ldconfig
 

curl -L https://github.com/openvenues/libpostal/releases/download/v1.0.0/parser.tar.gz -o $DATA_DIR/parser.tar.gz 
curl -L https://github.com/openvenues/libpostal/releases/download/v1.0.0/libpostal_data.tar.gz -o $DATA_DIR/libpostal_data.tar.gz 
curl -L https://github.com/openvenues/libpostal/releases/download/v1.0.0/language_classifier.tar.gz o $DATA_DIR/language_classifier.tar.gz 


mkdir -p $DATA_DIR/parser
tar -xvzf $DATA_DIR/parser.tar.gz  -C $DATA_DIR/parser

mkdir -p $DATA_DIR/libpostal_data
tar -xvzf $DATA_DIR/libpostal_data.tar.gz  -C $DATA_DIR/libpostal_data

mkdir -p $DATA_DIR/language_classifier
tar -xvzf $DATA_DIR/language_classifier.tar.gz  -C $DATA_DIR/language_classifier

echo $(date -u) > $DATA_DIR/last_updated
echo $(date -u) > $DATA_DIR/last_updated_parser
echo $(date -u) > $DATA_DIR/last_updated_language_classifier


./src/address_parser