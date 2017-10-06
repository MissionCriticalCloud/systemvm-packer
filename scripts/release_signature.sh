#!/bin/bash

set -x

date

# Bump the new version every day
SYSTEMVM_RELEASE=$(date +%-y.%-m.%-d)

echo "Cosmic Release $SYSTEMVM_RELEASE $(date)" > /etc/cosmic-release
