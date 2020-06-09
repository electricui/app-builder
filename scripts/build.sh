#!/usr/bin/env bash
set -ex

# Recreate the temporary directory
rm -rf tmp
mkdir tmp

# Process the package.json
jq '.repository="https://github.com/electricui/app-builder/" | .files = ["*.js", "index.d.ts", "bin"] | .preferUnplugged = true' app-builder-bin/package.json > tmp/package.json

clean () {
    # Clean up previous build artefacts 
    rm -rf "app-builder-bin-$1-$2"

    # Create the directories
    mkdir -p app-builder-bin-$1-$2/bin
} 

clean "linux" "ia32"
clean "linux" "x64"
clean "linux" "arm"
clean "linux" "arm64"
clean "darwin" "x64"
clean "win32" "x32"
clean "win32" "x64"

# Run our builds
GOOS=linux GOARCH=386 go build -ldflags='-s -w' -o app-builder-bin-linux-ia32/bin/app-builder .
GOOS=linux GOARCH=amd64 go build -ldflags='-s -w' -o app-builder-bin-linux-x64/bin/app-builder .
GOOS=linux GOARCH=arm go build -ldflags='-s -w' -o app-builder-bin-linux-arm/bin/app-builder .
GOOS=linux GOARCH=arm64 go build -ldflags='-s -w' -o app-builder-bin-linux-arm64/bin/app-builder .
GOOS=darwin GOARCH=amd64 go build -ldflags='-s -w' -o app-builder-bin-darwin-x64/bin/app-builder .
GOOS=windows GOARCH=386 go build -o app-builder-bin-win32-x32/bin/app-builder.exe .
GOOS=windows GOARCH=amd64 go build -ldflags='-s -w' -o app-builder-bin-win32-x64/bin/app-builder.exe .

post_process () {
    # Copy our JS and TS definiton files
    if [ "$1" == "win32" ]
    then
        cp app-builder-bin/index-win.js app-builder-bin-$1-$2/index.js
    else
        cp app-builder-bin/index.js app-builder-bin-$1-$2/index.js
    fi

    cp app-builder-bin/index.d.ts app-builder-bin-$1-$2/index.d.ts

    # Copy the readme
    cp readme.md app-builder-bin-$1-$2/README.md

    # Create our package.json
    jq ".name=\"@electricui/app-builder-bin-$1-$2\" | .description=\"app-builder precompiled binary for $2 $1\"" tmp/package.json > "app-builder-bin-$1-$2/package.json"
} 

post_process "linux" "ia32"
post_process "linux" "x64"
post_process "linux" "arm"
post_process "linux" "arm64"
post_process "darwin" "x64"
post_process "win32" "x32"
post_process "win32" "x64"