#!/bin/bash

set -x

configure_timeout() {
cat <<EOF> /etc/profile.d/tmout.sh
TTY=\$(tty)

if [[ \$TTY =~ /dev/ttyS?[0-9]+.* ]]; then
  TMOUT=600
  readonly TMOUT
  export TMOUT
fi
EOF

}

return 2>/dev/null || configure_timeout
