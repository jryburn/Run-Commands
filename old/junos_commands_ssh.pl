#!/usr/bin/perl

# junos_commands_ssh.pl
# Written by Justin Ryburn (jryburn@juniper.net)
# Last updated 02/16/12

use strict;
use warnings;
use Net::OpenSSH;

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
	open(LOG, ">$logfile");

	# setup up the SSH object for each router and login.
	print "Running commands on $router...";
	my $ssh = Net::OpenSSH->new("$user:$pw\@$router", timeout => 30);
    $ssh->error and die "unable to connect to remote host: $router\n";
    	
    # Set timestamping for each command.
    my $out = $ssh->capture("set cli timestamp\n") or
    	die "remote command failed: " . $ssh->error;
    print LOG $out;
    			
	# While loop for going through all the commands in the list.
	open(CMD, "$cmd_file");
	while (<CMD>) {
		chomp $_;
		my $cmd=$_;
		print LOG "$cmd\n";
		$out = $ssh->capture($cmd)
			or die "unable to run remote command $cmd\n";
		print LOG $out;
		print LOG "###############################################\n\n";
	}
	
	close(CMD); # Close out the commands file now that we are done.
	close(LOG); # Close the log file.
	print "done!\n";		
}

close(HOST); # Close out the host file now that we are done.

exit 0; # Exit the script cleanly!