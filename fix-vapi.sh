#!/bin/bash

# Work around bug where unowned compact class is not marked as unowned in the
# generated vapi file.

[ $# != 2 ] && echo "Usage: ./fix-vapi.sh <in.vapi> <out.vapi>" && exit 1

sed "s/public GRX.Font/public unowned GRX.Font/" $1 > $2

exit 0