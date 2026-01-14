#!/bin/bash
source "$(dirname "$BASH_SOURCE")"/macosarm64-gpl-shared.sh
FF_CONFIGURE="--enable-nonfree $FF_CONFIGURE"
LICENSE_FILE=""
