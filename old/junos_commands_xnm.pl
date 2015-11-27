#!/usr/bin/perl

# junos_commands_xnm.pl
# Written by Justin Ryburn (jryburn@juniper.net)
# Last updated 02/16/12

use strict;
use warnings;
use JUNOS::Device;

# Define all the global variables.
my $user="jnpr";
my $pw="pass123";
my $access ="telnet"; # access method/protocol options telnet|ssh|clear-text|ssl.
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

	# setup up the object for each router and login.
	print "Running commands on $router...";
	my $jnx = new JUNOS::Device(
		access => $access,
		login => $user,
		password => $pw,
		hostname => $router
	);
	unless ( ref $jnx ) {
		die "ERROR: can't connect to $router.\n";
	}
    				
	# While loop for going through all the commands in the list.
	open(CMD, "$cmd_file");
	while (<CMD>) {
		chomp $_;
		my $cmd=$_;
		my $res = $jnx->$cmd();
		unless ( ref $res ) {
			die "ERROR: $router: can't execute command $cmd.\n";
		}
		# Check and see if there were any errors in executing the command.
		# If all is well, output the response to our logfile.
		my $err = $res->getFirstError();
		if ($err) {
			print STDERR "ERROR: $router - ", $err->{message}, "\n";
		} else {
			#
			# Now output to the logfile.
			#
			$res->printToFile($logfile);
		}
	}
	
	# always close the connection
	$jnx->request_end_session();
	$jnx->disconnect();
	
	close(CMD); # Close out the commands file now that we are done.
	print "done!\n";		
}

close(HOST); # Close out the host file now that we are done.

exit 0; # Exit the script cleanly!