#!/usr/bin/env bash

pushd bin/Debug

export LD_LIBRARY_PATH=.:$LD_LIBRARY_PATH

./luaw ./res/testing.lua -v -Tb -n a b c

popd
