# README

With this setup you can create a `vagrant` base OS X VM / box.

This setup should be compatible with most Virtual Machine
tools / hypervisors supported by `vagrant`, like VirtualBox, Parallels or vSphere,
only the packaging depends on the actual tool.

You can find tool specific setup & packaging instructions below.

Table of Content:

0. Request a tool to be pre-installed
1. Create VM & OS X installation
  * how to create the base VM & install a vanilla OS X
2. Provisioning
  * how to prepare the required OS X environment, with preinstalled tools,
    based on a vanilla OS X installation
3. Packaging
  * how to save the create VM in a `vagrant` ready box format, which can then
    be simply used with `vagrant`


## Request a tool to be pre-installed

**If you'd like to add a tool** to be pre-installed you can create a
Pull Request, adding your changes to the `playbook.yml` ([Ansible](http://docs.ansible.com) playbook) of this repository.
*Please also add* a related test/report to the `system_report.sh` file,
which is used to test & list the pre-installed tools.

When a new version of this stack is available on [bitrise.io](https://www.bitrise.io)
we'll run `system_report.sh` and post the result into
the [bitrise.io GitHub repository](https://github.com/bitrise-io/bitrise.io), under the `system_reports` folder.


## Create VM & OS X installation

### VMware vSphere specific

* Create a new OS X VM
  * 4 GB RAM
  * 2 CPU
  * about 100 GB disk space
* Start the VM
* Install OS X:
  * OS X won't see the hard drive, you'll have to open Disk Utility (you can
    find it in the menu bar of the OS X installer) and format the disk
  * Select the 100 GB disk on the left side, and then Erase it
  * Format: Mac OS Extended (Journaled)
  * Name: Macintosh HD
  * Clone Disk Utility, you should now be able to select this disk for the install.
  * Follow the: OS X Install guide (common) section
* Wait for Spotlight indexing to finish
* Shut down the VM and remove the OS X Installer ISO (cdrom)
* Save it as a "vanilla box" (as a VM or even better, as a Template)
* When preparing for a specific setup (e.g. Xcode version)
  * clone this "vanilla box"
  * update to the OS X version you want
  * double check the "Once installed:" section of "OS X Install guide (common) section"
    * in some cases OS X version update might turn off e.g. Remote Login!
  * install the VMware Tools
  * check and wait if Spotlight is indexing
  * Save it as an environment specific "base box"
  * Continue with Provisioning


### Parallels specific [no longer maintained]

*We used this setup for quite a long time, but not anymore,
and so this setup is no longer actively maintained.
Feel free to extend this guide if you have more information / if the
guide is not up-to-date anymore.*

* Create a new OS X VM
  * Select the "from DVD or image file" option
    * Select the "Image file" option and Drag-and-Drop the "Install OS X ..." (.app) installer
    * Parallels will most likely create a "bootable" image from the "Install OS X ..." installer
    * Once it's ready make sure to enable the "Customize settings before installation" option
  * Set these VM settings:
    * Options
      * Advanced: Do not sync the time from the host OS X (without the Parallels Tools installed in the VM it's not an option anyway)
      * Advanced: don't share the clipboard
    * Hardware
      * 4 GB RAM
      * 2 CPU
      * 32 MB Video memory
    * Security
      * enable Isolate Mac from virtual machine (disables shared folders, clipboard sharing, etc.)
* Start the VM
* Install OS X:
  * Follow the: OS X Install guide (common) section

### VirtualBox specific [experimental / not maintained]

*Experimental: we don't actively use this configuration.
This guide was created for VirtualBox 4.x, might or might not work with 5.x .
Feel free to extend this guide if you have more information / if the
guide is not up-to-date anymore.*

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
      * 4096 MB RAM
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
* Start the VM
* Install OS X:
  * Follow the: OS X Install guide (common) section

**Important Note**

> VirtualBox's snapshot rollback doesn't start the VM if the snapshot
> was taken when the VM was running. Parallels does this (turns the VM on
> even if it's not running when you roll back to the snapshot) but
> VirtualBox does not, you have to ensure the VM is turned on.


## OS X Install guide (common)

* During install select the default options everywhere, except:
  * Apple ID: select "Don't sign in"
* Username should be: "vagrant" with the same password ("vagrant")
  * Turn off "require password to unlock screen"
  * Turn off "Set time zone based on current location"
  * Turn off "Send Diagnostics & Usage data to Apple"
* Register this Mac: don't register

Once installed:

* Enable "Remote Login" in the Sharing Preference Pane. This enables SSH.
* Disable automatic updates in Preferences - App Store
* Disable every sleep option in Preferences - Energy Saver
* Make sure automatic login is enabled in Preferences - Users and Groups (Login Options).
* Disable the Screen Saver
* Check & wait for Spotlight to finish indexing
* Restart

## Provisioning

### Install Xcode - can be saved as an intermediate template

* Run `xcode-select --install` and install the Xcode Command Line Tools (popup should appear)
* __Wait for the CLT install to finish__, or else the `/usr/include` paths won't be created!
* Install the Xcode version you want to use, to the canonical path (`/Applications/Xcode.app`)
  * Open it after the install, accept the EULA
  * Create a test iOS project with UI Tests, build & run tests - allow Developer mode when prompted
  * Create a test Mac OS X project with UI Tests, build & run tests - allow Accessibility for UI tests when prompted
  * install all the available SDKs and Simulators
    * Xcode -> Preferences -> Downloads -> Components
  * open the iOS Simulator from Xcode -> Open Developer Tools (in the statusbar menu) -> iOS Simulator and validate that it works

### Final steps: Run auto setups, with ansible

* Check the available OS X updates in the App Store (don't sign into the App Store!),
  and install the system updates, then reboot the VM.

* To activate the vagrant insecure key, which will be used during the setup:
  * If your ssh-agent is not running: `eval $(ssh-agent)`
  * then: `ssh-add ./vagrant-insecure_private_key`

* For a base Vagrant specific setup use the `vagrant-setup-playbook.yml` - run it with `ansible`
  * From another host:
    * open `bitrise.yml` from this directory, and define the environment variables listed at the top
      * you should define those in the `.bitrise.secrets.yml`, saved into this directory
    * that's all, you can now run `bitrise run vagrant-setup`

* Now you can run the actual VM environment setup:
  * with bitrise CLI: `bitrise run provision-vm`
* Right now we have to run one more thing, to create the deprecated xcode version mapping files:
  * with bitrise CLI: `bitrise run DEPRECATED-create-xcode-version-mapping`
  * This'll be removed in the near future, but right now required for backward compatibility
* NOTE: you can also `bitrise trigger step/X` these workflows, where `X` is the order of the step
  * e.g. `bitrise trigger step/1` runs the same as `bitrise run vagrant-setup`, as that's the first Bitrise CLI "step" of this guide

### Xamarin notes

To add the Xamarin specific bits you should also run this,
after you ran the previous steps: `bitrise run provision-xamarin-vm`


## Layout of this repository

* Root (the directory this README file is in) contains the main `ansible` setup playbooks, and this guide/overview README
* `tools` dir: will be synchronized as-it-is to the Virtual Machine, under `$HOME/bitrise/tools`


## OS X version notes

* This repository is meant to be used / tested with OS X El Capitan (10.11)
* Other OS X versions should also work, but might require minor modifications
  * Previous OS X versions (up until 10.11) stored the `sshd_config` in `/etc/sshd_config` - this changed in `10.11` to `/etc/ssh/sshd_config`
