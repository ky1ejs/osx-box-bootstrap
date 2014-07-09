#!/bin/bash

brew install go

echo 'export PATH="$PATH:/usr/local/opt/go/libexec/bin"' >> ~/.bashrc
echo 'export GOPATH="$HOME/go"' >> ~/.bashrc
# bash_profile should load bashrc
source ~/.bash_profile
mkdir -p "$GOPATH/src"
mkdir -p "$GOPATH/bin"
mkdir -p "$GOPATH/pkg"