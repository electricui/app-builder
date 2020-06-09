#!/usr/bin/env bash
set -ex

# This file is only relevant to internal Electric UI systems.

# Login with user / pass via ENV var since our local registry proxy doesn't use tokens for this
/usr/bin/expect <<EOF
set timeout 10
spawn npm login
match_max 100000

expect "Username"
send "$REGISTRY_USERNAME\r"

expect "Password"
send "$REGISTRY_PASSWORD\r"

expect "Email"
send "$REGISTRY_EMAIL\r"

expect {
   timeout      exit 1
   expect eof
}
EOF

publish () {
    # Publish the version
    npm publish "app-builder-bin-$1-$2"
}

publish "linux" "ia32"
publish "linux" "x64"
publish "linux" "arm"
publish "linux" "arm64"
publish "darwin" "x64"
publish "win32" "x32"
publish "win32" "x64"