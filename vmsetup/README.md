# Setup

After the OS Install wait at least 10 minutes - for OS X indexing and other system maintenance processes.

**important**

* when you create the OS X user the username should be "vagrant" and the password should be "vagrant" too


## Manual setup steps

* install OS X updates (for 10.9 Mavericks - don't upgrade to 10.10!)
* enable SSH : System Preferences / Sharing / Remote Login: enable
* set the user (vagrant) to don’t require password to sudo
    * add to the end ($ sudo visudo): vagrant ALL=(ALL) NOPASSWD: ALL
* install Xcode
    * if you install Xcode from the App Store **don't forget to sign out from the App Store!**
      * but installing from DMG is preferred!
    * after install run it at least once
    * open Organizer and Enable Developer Mode for the Mac
      * or run: $ sudo DevToolsSecurity -enable
    * and install all the available SDKs
* run: $ xcode-select --install
    * this have to be run in GUI mode, it will present a popup
* disable App Store automatic updates
* disable Energy Saver settings: System Preferences / Energy Saver; disable every sleep setting
* turn on "auto login to user"
* turn off screen saver

## Auto setup

After the manual setup steps you can start the automatic setup.

Just run **setup.sh** inside the Virtual Machine.

    $ bash setup.sh
