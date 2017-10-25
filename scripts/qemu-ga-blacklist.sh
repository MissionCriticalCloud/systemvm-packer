#!/usr/bin/env bash

set -x

# Make sure qemu-ga does not have a BLACKLIST_RPC line or else Cosmic
# won't be able to inject its config

cat > /etc/sysconfig/qemu-ga << EOL
# This is a systemd environment file, not a shell script.
# It provides settings for "/lib/systemd/system/qemu-guest-agent.service".

# Comma-separated blacklist of RPCs to disable, or empty list to enable all.
#
# You can get the list of RPC commands using "qemu-ga --blacklist='?'".
# There should be no spaces between commas and commands in the blacklist.

# Fsfreeze hook script specification.
#
# FSFREEZE_HOOK_PATHNAME=/dev/null           : disables the feature.
#
# FSFREEZE_HOOK_PATHNAME=/path/to/executable : enables the feature with the
# specified binary or shell script.
#
# FSFREEZE_HOOK_PATHNAME=                    : enables the feature with the
# default value (invoke "qemu-ga --help" to interrogate).
FSFREEZE_HOOK_PATHNAME=/etc/qemu-ga/fsfreeze-hook
EOL

