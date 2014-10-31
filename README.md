osx-box-bootstrap
=================

Bitrise OS X Virtual Machine bootstrap scripts.

> This repository contains a guide (manual setup steps)
> and automation scripts to create and provision an OS X Virtual Machine
> which can be used for build automation, continuous integration,
> continuous delivery or any other automation workflow.

> The Virtual Machine contains the Bitrise specific (minimal) setup
> so it can be used for building through Bitrise right after the provision.


# Dependency management

We use [DepMan](https://github.com/viktorbenei/depman) to manage
dependencies of this repository.


# Base VM (box) setup

After the OS Install wait at least 10 minutes - for OS X indexing and other system maintenance processes.

*You should wait at least for the OS X / Spotlight indexing to finish before packaging the VM*

*You can do the manual setup steps in the meantime!*

**important**

When you create the OS X user the username should be *vagrant* and
the password should be *vagrant* too.


## Manual setup steps

* install OS X updates (for 10.9 Mavericks - don't upgrade to 10.10, it's not yet supported by Bitrise)
* enable SSH : System Preferences / Sharing / Remote Login: enable
* for vagrant specific setup guide you can check these official guides:
  * [https://docs.vagrantup.com/v2/virtualbox/boxes.html](https://docs.vagrantup.com/v2/virtualbox/boxes.html)
  * [https://docs.vagrantup.com/v2/boxes/base.html](https://docs.vagrantup.com/v2/boxes/base.html)
  * include vagrant's insecure public key in the ~/.ssh/authorized_keys file!
//
// This will be handled by the Ansible playbook:
//* set the user (vagrant) to don’t require password to sudo
//    * add to the end ($ sudo visudo): vagrant ALL=(ALL) NOPASSWD: ALL
* run: $ xcode-select --install
    * this have to be run in GUI mode, it will present a popup
      and you'll have to accept the EULA
* disable App Store automatic updates
* disable Energy Saver settings: System Preferences / Energy Saver; disable every sleep setting
* turn on "auto login to user"
* turn off screen saver
* install Xcode
  * if you install Xcode from the App Store **don't forget to sign out from the App Store!**
    * BUT installing from DMG is preferred, from Apple's download site: [https://developer.apple.com/downloads/index.action](https://developer.apple.com/downloads/index.action)
  * after install run it at least once
  * open Organizer and Enable Developer Mode for the Mac
    * or run: $ sudo DevToolsSecurity -enable
  * install all the available SDKs and iOS Simulators (or the ones you want to use)
    * Xcode -> Preferences -> Downloads -> Components
  * open the iOS Simulator from Xcode -> Open Developer Tools (in the statusbar menu) -> iOS Simulator
    and validate that it works
  * Bitrise specific note: download and setup all the required
    Xcode versions as specified in the Bitrise Dev Center
    [Xcode version support guideline](http://devcenter.bitrise.io/docs/xcode-version-support.html)

### Parallels

To isolate / secure the VM you should disable every sharing option.

*Note: you don't even have to install the Parallels Tools,
the VM is fully functional without it except shared folders
which would be disabled anyway for security*

Do/check the following settings in Parallels - Select the VM -
Virtual Machine menu - Configure:

* Options
  * Advanced: Do not sync the time from the host OS X (without the Parallels Tools installed in the VM it's not an option anyway)
  * Advanced: don't share the clipboard
* Security
  * enable Isolate Mac from virtual machine (disables shared folders, clipboard sharing, etc.)

## Auto setup

*It's recommended to create a VM snapshot before you would start
the auto setup, for easier debugging / issue fixing*

After the manual setup steps you can start the automatic setup.

The auto setup uses [Ansible](http://www.ansible.com/home).
You can install it on your host OS with Homebrew:

  $ brew install ansible

You can find the docs at [http://docs.ansible.com/](http://docs.ansible.com/)

**Update the included components in this repository:**

To update the dependencies of this repository you have to install [DepMan](https://github.com/viktorbenei/depman), then in this folder:

  $ depman update  

Run the *setup_playbook.yml* with ansible:

  $ ansible-playbook -e bitrise_box_version=[box-version, example: r2p3] --private-key ~/.vagrant.d/insecure_private_key -i hosts setup_playbook.yml

Or instead of specifying --private-key you can:

  $ ssh-add ~/.vagrant.d/insecure_private_key

And after that from the same terminal you can simply:

  $ ansible-playbook -e bitrise_box_version=[box-version, example: r2p3] -i hosts setup_playbook.yml

*NOTE:* with a default VirtualBox Vagrant setup the included *hosts*
file should be fine. Change the IP and Port in hosts if you have to.

If you already imported the base box into vagrant and started it
with *vagrant up* you can call *$ vagrant ssh-config* to get the IP
and port required and place it into the *hosts* file.

You can inspect the special install logs in the *~/Desktop/debug.log* file
and delete it if everything is OK.


# Experimental: VirtualBox support

VirtualBox's OS X support is still marked as experimental.

Some notes for experimenting with VirtualBox based OS X VMs:

* how to install OS X guest in VirtualBox running on OS X: [http://engineering.bittorrent.com/2014/07/16/how-to-guide-for-mavericks-vm-on-mavericks/](http://engineering.bittorrent.com/2014/07/16/how-to-guide-for-mavericks-vm-on-mavericks/)
  * detailed step-by-step guide, with images, from step 0 (downloading OS X installer from the App Store) to up-and-running
  * NOTES:
    * the new Haswell based Intel CPUs are still not yet properly supported
    and require a (quick) workaround - detailed in the article.
    * to tweak the CPU performance you could try other CPU IDs:
      * VBoxManage modifyvm <vmname> --cpuidset 1 000206a7 02100800 1fbae3bf bfebfbff [source](https://www.virtualbox.org/ticket/12802)
    * our best configuration so far (set it before starting the VM!)
      * 2 CPU, execution cap 100%
      * 3072 MB RAM (4096 if you can afford it)
      * Chipset: PIIX3
      * 128MB VRAM (video ram)
      * enable all the acceleration features (except 2D acceleration)
      * if required: VBoxManage modifyvm <vmname> --cpuidset 1 000206a7 02100800 1fbae3bf bfebfbff
* to be able to SSH into the VM through the default NAT network adapter
  (which is required for vagrant) you have to set up a port forwarding
  with: host 127.0.0.1 port 2222 -> guest 22
    * vagrant does this automatically but if you want to test
      the SSH login of the box before packaging it you'll have to
      do it yourself

**Important Note**

> VirtualBox's snapshot rollback doesn't start the VM if the snapshot
> was taken when the VM was running. Parallels does this (turns the VM on
> even if it's not running when you roll back to the snapshot) but
> VirtualBox does not, you have to ensure the VM is turned on.


## After the install of OS X in VirtualBox

* do the *Manual setup steps*
* if you want to you can create a box from this base setup, and
  run the *Auto setup* on the actual box then package it again.
  This can allow you to save "snapshots" of the VM while you do
  the setup (useful for later use) and you can even use
  the *vagrant sahara* snapshot plugin during the setup / testing
  for easy and quick snapshot management.
  For this do the following steps in addition to the Manual setup steps:
  * you can setup a base port forwarding so you can SSH into the machine
    which can help you with the steps below (if you want to perform
    these through SSH, because VirtualBox doesn't have the Guest Additions
    for OS X at the moment, so no copy-pasting from host to guest)
  * set the user (vagrant) to don’t require password to sudo
  * download vagrant's insecure public key and store into authorized_keys
    * $ mkdir ~/.ssh && curl -o ~/.ssh/authorized_keys https://raw.githubusercontent.com/mitchellh/vagrant/master/keys/vagrant.pub
    * $ chmod 0700 ~/.ssh && chmod 0600 ~/.ssh/authorized_keys
* do the *Auto setup* steps


## Packaging a (base) box

*Don't forget to remove the snapshots you used before packaging
(for smaller box)*

### VirtualBox

  $ vagrant package --base [vm name in VirtualBox]

This will create a package.box file in the current directory you're in.

**NOTE:** it takes a **very long** time. ~30 minutes on a MacBook Pro.

Once you have a running Vagrant VM you can use the **repackage** script
to package a new box based on the one in Vagrant.

Use the *_scripts/[provider]-repackage-box.sh* script.

### Parallels

You can use the *_scripts/parallels-repackage-box.sh* script.


### Import the box

  $ vagrant box add --clean --force --name [boxname you will include in Vagrantfile] [box/file/path.box]

After this you can simply `$ vagrant up` as you would with any other vagrant box
if you have a Vagrantfile with **config.vm.box = "[boxname you will include in Vagrantfile]"**

### Vagrantfile

**VirtualBox:**

It seems that headless mode is not properly supported yet in VirtualBox. You'll have to enable
the GUI in your Vagrantfile:

  config.vm.provider "virtualbox" do |vb|
    # Don't boot with headless mode
    vb.gui = true
  end



# Bootstrapping

**scripts/bootstrap.sh** : this bootstrap script runs every time Bitrise starts to interact with the Virtual Machine.

Performs a general base "refresh" of the Virtual Machine so
the Bitrise services can interact with it (for example synchronizes the time
on the VM).

The bootstrapping runs every time Bitrise starts to
interact with the Virtual Machine, before a session (ex: build session).


## System Upgrade

* **upgrade.sh** : performs general system upgrade.

To upgrade core system packages and components you can use **upgrade.sh**

### Warning!

Always test the upgrades carefully! It can break things (for example a new major version of a program installed with brew)
