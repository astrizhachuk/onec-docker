#!/bin/sh

if [ -f "/init" ]; then
    /init &
fi

"$@"
