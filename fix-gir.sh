#!/bin/bash

set -e

# add missing shared-library attribute
sed -e "s/-buggy//" -e "s/\(<namespace.*\)\(>\)/\1 shared-library=\"$1\"\2/" $2 > $3
