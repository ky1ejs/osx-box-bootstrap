#!/bin/bash


function print_and_do_command {
  echo "-> $ $@"
  $@
}

function print_and_do_command_exit_on_error {
  print_and_do_command $@
  if [ $? -ne 0 ]; then
    echo " [!] Failed!"
    exit 1
  fi
}

# boostrap.sh
print_and_do_command_exit_on_error cp scripts/bootstrap.sh ~/.bootstrap.sh
print_and_do_command_exit_on_error chmod +x ~/.bootstrap.sh


# step_agent
print_and_do_command_exit_on_error cp step-agent/bin/step_agent_osx ~/.step_agent

# git clone scripts
print_and_do_command_exit_on_error cp steps-git-clone/ssh_no_prompt.sh ~/ssh_no_prompt.sh
print_and_do_command_exit_on_error chmod +x ~/ssh_no_prompt.sh

print_and_do_command_exit_on_error cp steps-git-clone/git_clone.rb ~/git_clone.rb

# profiles
print_and_do_command_exit_on_error cp profiles/bitrise_profile ~/.bitrise_profile
print_and_do_command_exit_on_error cp profiles/bashrc ~/.bashrc
print_and_do_command_exit_on_error cp profiles/profile ~/.profile
print_and_do_command_exit_on_error cp profiles/bash_profile ~/.bash_profile

# (i) bash_profile sources profile, which sources bashrc which sources bitrise_profile
print_and_do_command_exit_on_error source ~/.bash_profile
