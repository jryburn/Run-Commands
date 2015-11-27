Run-Commands
===========

Utility to run commands on Junos devices using Netconf


## FEATURES
* Run commands on a given list of devices.
* Output saved to a text file.
* Multiple commands and multiple devices are supported.

## REQUIREMENTS
* Tested on python2.7
* junos-pyez library (https://github.com/Juniper/py-junos-eznc)

## USAGE

````
usage: junos_commands.py [-h] [-d DEVICE] [-l DEVICE_LIST] [-c COMMAND]
                         [-f FILE] [-u USER] [-p PASSWORD] [-o OUTPUT]

Utility to run commands on Junos devices

optional arguments:
  -h, --help            show this help message and exit
  -d DEVICE, --device DEVICE
                        Device to run commands on
  -l DEVICE_LIST, --device-list DEVICE_LIST
                        File containing list of devices to run commands on
  -c COMMAND, --command COMMAND
                        Command to run
  -f FILE, --file FILE  File containing commands to run
  -u USER, --user USER  Username to login to device
  -p PASSWORD, --password PASSWORD
                        Password to login to device
  -o OUTPUT, --output OUTPUT
                        Output directory for files
````
