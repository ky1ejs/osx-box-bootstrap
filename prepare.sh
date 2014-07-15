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
cp step-agent/bin/step_agent_osx ~/.step_agent
if [ $? -ne 0 ]; then
  exit 1
fi

# git clone scripts
cp steps-git-clone/ssh_no_prompt.sh ~/ssh_no_prompt.sh
if [ $? -ne 0 ]; then
  exit 1
fi
chmod +x ~/ssh_no_prompt.sh
if [ $? -ne 0 ]; then
  exit 1
fi

cp steps-git-clone/git_clone.rb ~/git_clone.rb
if [ $? -ne 0 ]; then
  exit 1
fi

# profiles

cp profiles/bitrise_profile ~/.bitrise_profile
if [ $? -ne 0 ]; then
  exit 1
fi

cp profiles/bashrc ~/.bashrc
if [ $? -ne 0 ]; then
  exit 1
fi

cp profiles/profile ~/.profile
if [ $? -ne 0 ]; then
  exit 1
fi

cp profiles/bash_profile ~/.bash_profile
if [ $? -ne 0 ]; then
  exit 1
fi

# (i) bash_profile sources profile, which sources bashrc which sources bitrise_profile
source ~/.bash_profile
if [ $? -ne 0 ]; then
  exit 1
fi
