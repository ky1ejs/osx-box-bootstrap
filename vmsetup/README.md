# Setup

After the OS Install wait at least 10 minutes - for OS X indexing and other system maintenance processes.


## Manual setup steps

* enable SSH : System Preferences / Sharing / Remote Login: enable
* set the user (vagrant) to don’t require password to sudo
    * add to the end ($ sudo visudo): vagrant ALL=(ALL) NOPASSWD: ALL
* run: $ xcode-select --install
    * this have to be run in GUI mode, it will present a popup

## Auto setup

After the manual setup steps you can start the automatic setup.

Just run **setup.sh** inside the Virtual Machine.

    $ bash setup.sh