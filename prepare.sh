#!/bin/bash

# boostrap.sh
cp scripts/bootstrap.sh ~/.bootstrap.sh
if [ $? -ne 0 ]; then
  exit 1
fi
chmod +x ~/.bootstrap.sh
if [ $? -ne 0 ]; then
  exit 1
fi

# step_agent
cp scripts/step_agent.rb ~/.step_agent.rb
if [ $? -ne 0 ]; then
  exit 1
fi

# git clone scripts
cp step-git-clone/ssh_no_prompt.sh ~/ssh_no_prompt.sh
if [ $? -ne 0 ]; then
  exit 1
fi
chmod +x ~/ssh_no_prompt.sh
if [ $? -ne 0 ]; then
  exit 1
fi

cp step-git-clone/git_clone.rb ~/git_clone.rb
if [ $? -ne 0 ]; then
  exit 1
fi