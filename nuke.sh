#!/bin/bash

# Wipe out build dir and re-run cmake

if [ -z $1 ]
then
	echo "Must specify directory name"
	exit 1
fi

build_dir=$1
if [[ ${build_dir} == *desktop* ]]
then
	echo "Configuring for desktop"
	dekstop_flag="-DEV3DEVKIT_DESKTOP=1"
fi

rm -rf ${build_dir}
mkdir ${build_dir} --mode 744
cd ${build_dir}
cmake ../ -DCMAKE_BUILD_TYPE=debug ${dekstop_flag}