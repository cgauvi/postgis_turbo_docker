#! /bin/bash

apt purge -y cmake
wget https://github.com/Kitware/CMake/releases/download/v3.20.0/cmake-3.20.0.tar.gz --no-check-certificate
tar -zxvf cmake-3.20.0.tar.gz
cd cmake-3.20.0

bash ./bootstrap
make install
cmake --version

# Make sure available to all
cp /usr/local/bin/cmake /usr/bin/