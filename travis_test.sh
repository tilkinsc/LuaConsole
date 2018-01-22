#!/usr/bin/env bash

pushd bin/Debug

./luaw testing.lua -v -Tb -n a b c

popd
