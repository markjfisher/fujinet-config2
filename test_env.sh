#!/bin/bash

mkdir -p _cache/build-tmp > /dev/null 2>&1

export SOFT65C02_BUILD_DIR=`realpath ./_cache/build-tmp`
export WS_ROOT=`realpath .`
export UNIT_TEST_DIR=`realpath ./testing/unit`
