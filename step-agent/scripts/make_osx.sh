#!/bin/bash

# build
echo "Building..."
go build

# move the created 'main' binary into 'bin/step_agent_osx'
echo "Moving to bin..."
mkdir -p bin
mv step-agent-go bin/step_agent_osx

echo "Done"