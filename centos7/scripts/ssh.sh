#!/usr/bin/env bash

set -x

mkdir ~/.ssh
chmod 700 ~/.ssh

systemctl enable sshd
