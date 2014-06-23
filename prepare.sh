#!/bin/bash

cp scripts/bootstrap.sh ~/.bootstrap.sh
chmod +x ~/.bootstrap.sh

cp scripts/step_agent.rb ~/.step_agent.rb

cp step-git-clone/ssh_no_prompt.sh ~/ssh_no_prompt.sh
chmod +x ~/ssh_no_prompt.sh

cp step-git-clone/git_clone.rb ~/git_clone.rb