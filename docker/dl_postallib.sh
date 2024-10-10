
#! /bin/bash

mkdir -p ./local_postal_lib_data

if [ ! -f ./local_postal_lib_data/parser.tar.gz ]; then
    curl --insecure -L https://github.com/openvenues/libpostal/releases/download/v1.0.0/parser.tar.gz -o ./local_postal_lib_data/parser.tar.gz
else
    echo "parser already downloaded"
fi

if [ ! -f ./local_postal_lib_data/parser.tar.gz ]; then
    curl --insecure -L https://github.com/openvenues/libpostal/releases/download/v1.0.0/libpostal_data.tar.gz -o ./local_postal_lib_data/libpostal_data.tar.gz
else
    echo "libpostal_data already downloaded"
fi

if [ ! -f ./local_postal_lib_data/parser.tar.gz ]; then
    curl --insecure -L https://github.com/openvenues/libpostal/releases/download/v1.0.0/language_classifier.tar.gz -o ./local_postal_lib_data/language_classifier.tar.gz
else
    echo "language_classifier already downloaded"
fi