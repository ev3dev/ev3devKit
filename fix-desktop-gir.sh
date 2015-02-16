#!/bin/bash

set -e

# add missing include and fix names to match new file name
sed -e "s/<package/<include name=\"$1\" version=\"$2\"\/>\n<package/" -e "s/-buggy//" $3 > $4
