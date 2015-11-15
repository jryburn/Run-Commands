#!/usr/bin/perl

# junos_commands_telnet.pl
# Written by Justin Ryburn (jryburn@juniper.net)
# Last updated 02/15/12

use Net::Telnet;
use strict;
use warnings;

# Define all the global variables.
my $user="jnpr";
my $pw="pass123";
my $host = "routers.txt"; #List of the routers to configure.
my $cmd_file="commands.txt"; #Configurations to change on these routers.

# Get the date for use in log filenames.
my ($sec,$min,$hour,$mday,$mon,$year)=localtime(time);
$mon += 1;
$year += 1900;

# While loop for going through all the routers in the list.
open (HOST, "$host");
while (<HOST>){
	chomp $_;
	my $router=$_;
	my $logfile = "$router.$mon\_$mday\_$year.$hour:$min:$sec.txt";

	# setup up the telnet object.
	my $telnet = new Net::Telnet (
		timeout => 10,
		prompt => '/>/',
		input_log => $logfile
	);
	
	# login to each device
	print "Running commands on $router...";
	$telnet->open($router);
	$telnet->login($user, $pw);
	
	# Set timestamping for each command.
	$telnet->cmd("set cli timestamp\n");
		
	# While loop for going through all the commands in the list.
	open(CMD, "$cmd_file");
	while (<CMD>) {
		chomp $_;
		my $cmd=$_;
		$telnet->cmd("$cmd");
	}
	
	close(CMD); # Close out the commands file now that we are done.
	
	$telnet->close(); # Logout of the router.
	
	print "done!\n";
	
}
close(HOST); # Close out the host file now that we are done.

exit 0; # Exit the script cleanly!