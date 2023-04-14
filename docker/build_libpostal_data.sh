
#! /bin/bash

DATA_DIR=/opt/libpostal_data

tar -xvzf $DATA_DIR/parser.tar.gz  -C $DATA_DIR/libpostal/
rm $DATA_DIR/parser.tar.gz

tar -xvzf $DATA_DIR/libpostal_data.tar.gz  -C $DATA_DIR/libpostal/
rm $DATA_DIR/libpostal_data.tar.gz

tar -xvzf $DATA_DIR/language_classifier.tar.gz  -C $DATA_DIR/libpostal/
rm $DATA_DIR/language_classifier.tar.gz


echo $(date -u) > $DATA_DIR/last_updated
echo $(date -u) > $DATA_DIR/last_updated_parser
echo $(date -u) > $DATA_DIR/last_updated_language_classifier

cd /libpostal
#/libpostal/src/address_parser