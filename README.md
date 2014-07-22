osx-box-bootstrap
=================

Bitrise OS X Virtual Machine bootstrap scripts

Uses [DepMan](https://github.com/viktorbenei/depman) for dependency management


# Parts


## VM Setup

To provision a brand new Virtual Machine - do the setups, automatically as much as possible.


## Bootstrapping

* **prepare.sh** : prepares the Virtual Machine for bootstrapping.
* **scripts/bootstrap.sh** : this bootstrap script runs every time Bitrise starts to interact with the Virtual Machine.

Performs a general base setup of the Virtual Machine so the Bitrise services can interact with it.

Part of the bootstrapping runs every time Bitrise starts to interact with the Virtual Machine, before a session (ex: build session).



## System Upgrade

* **upgrade.sh** : performs general system upgrade.

To upgrade core system packages and components you can use **upgrade.sh**

### Warning!

Always test the upgrades carefully! It can break things (for example a new major version of a program installed with brew)