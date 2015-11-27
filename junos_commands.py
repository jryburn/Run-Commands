#!/usr/bin/python

'''
junos_commands.py

Written by Justin Ryburn (jryburn@juniper.net)
Last revised: 11/24/15

This script is designed to log in to a list of Junos based devices and run a
list of commands. The commands and devices are required parameters, everything
else can be assumed or gathered from the user at run time.
'''

# Import the needed modules
from jnpr.junos import Device
from jnpr.junos.utils.config import Config
from jnpr.junos.exception import *
from getpass import *
import os, sys, argparse, time

# Define the default settings.
defaults = {
    'devices': [],
    'commands': [],
    'outdir': 'output',
    'user': '',
    'password': ''
}

# Parse the arguments given by the user.
def parse_arguments(arguments):
    parser = argparse.ArgumentParser(description="Utility to run commands on Junos devices")
    parser.add_argument("-d", "--device", help="Device to run commands on")
    parser.add_argument("-l", "--device-list", help="File containing list of devices to run commands on")
    parser.add_argument("-c", "--command", help="Command to run")
    parser.add_argument("-f", "--file", help="File containing commands to run")
    parser.add_argument("-u", "--user", help="Username to login to device")
    parser.add_argument("-p", "--password", help="Password to login to device")
    parser.add_argument("-o", "--output", help="Output directory for files")
    args = parser.parse_args()
    return args

# Get the list of devices from the input file.
def get_device_list(file):
    devices = []
    for device in open(file, 'rU'):
        devices.append(device.strip())
    return devices

# Get the list of commands to run.
def get_commands_list(file):
    commands = []
    for command in open(file, 'rU'):
        commands.append(command.strip())
    return commands

# Run the commands against the routers.
def run_commands(devices, user, password, commands, todir):
    if not os.path.exists(todir):
        os.mkdir(todir)
    for device in devices: # Open each device
        print 'Trying device: %s \n' % device
        outfile = file(os.path.join(todir, device + time.strftime ('%Y%m%d.%H:%M:%S') + '.txt'), 'w')
        dev = Device(device, user=user, password=password, gather_facts=False)
        try:
            dev.open()
        except ConnectError:
            print "ERROR: Unable to connect to %s." % device
            continue
        for command in commands:
            print 'Running command: %s\n' % command
            outfile.write('\n**** %s ****' % command)
            outfile.write(dev.cli(command, warning=False))
        dev.close()
    return

# Define the main function
def main():
    args = parse_arguments(sys.argv) # Process command line arguments

    # Set user to connect as
    if args.user:
        user = args.user
    elif defaults['user'] != '':
        user = defaults['user']
    else:
        user = getuser()

    # Set password for connecting
    if args.password:
        password = args.password
    elif defaults['password'] != '':
        password = defaults ['password']
    else:
        password = getpass('Password for %s: ' % user)

    # Generate device list
    if args.device:
        devices = [args.device]
    elif args.device_list:
        devices = get_device_list(args.device_list)
    elif defaults['devices'] != []:
        devices = defaults['devices']
    else:
        print 'ERROR: No device(s) specified'
        sys.exit(1)

    # Set output directory
    if args.output:
        todir = args.output
    else:
        todir = defaults['outdir']

    # Build the list of commands to run
    if args.command:
        commands = [args.command]
    elif args.file:
        commands = get_commands_list(args.file)
    elif defaults['commands'] != []:
        commands = defaults['commands']
    else:
        print 'ERROR: No commands were specified'
        sys.exit(1)

    # Run commands on device
    run_commands(devices, user, password, commands, todir)

# Main function call
if __name__ == '__main__':
    main()
