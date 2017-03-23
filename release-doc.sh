#!/bin/bash
#
# Maintainer script to build and push documentation

set -e

GIT_REMOTE_URL=git@github.com:ev3dev/ev3devKit
DOC_DIR=valadoc

RTD_VERSION=$1
RTD_VERSION2=$2

if [ ! -n "$RTD_VERSION" ]; then
    echo "must specify version for readthedocs.org"
    exit 1
fi

mkdir build-doc
cd build-doc
cmake -D CMAKE_BUILD_TYPE=Release ..
make doc
mkdir git
cd git
git init
git remote add origin $GIT_REMOTE_URL
git checkout -b c-api-docs/$RTD_VERSION
cp -R ../$DOC_DIR/* .
git add .
git commit -m "documentation"
git push --force origin c-api-docs/$RTD_VERSION
if [ -n "$RTD_VERSION2" ]; then
    git push --force origin HEAD:c-api-docs/$RTD_VERSION2
fi
cd ../..
rm -rf build-doc
