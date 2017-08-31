#!/bin/bash
#
# Maintainer script to build and push documentation

set -e

base_dir=$(dirname $(readlink -f $0))
build_dir=${base_dir}/doc-build
html_extra_dir=${base_dir}/doc/sphinx/_html_extra

rm -rf ${html_extra_dir}/vala-api

mkdir -p ${html_extra_dir}/vala-api

rm -rf ${build_dir}
cmake -D CMAKE_BUILD_TYPE=Release -B${build_dir} -H${base_dir}
make -s -C ${build_dir} doc

cp -R ${build_dir}/valadoc/* ${html_extra_dir}/vala-api

rm -rf ${build_dir}
