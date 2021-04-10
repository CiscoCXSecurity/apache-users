#!/usr/bin/perl -w

=head1 NAME

apache2 - Username Enumeration through Apache UserDir

=head1 DESCRIPTION

This perl script will enumerate the usernames on a unix system that use the apache module UserDir.

=head1 USAGE

Usage:  ./apache2.pl [-h host] [-p port] [-l dictionary] [-e response code] [-s ssl on/off] [-t threads]

=head1 AUTHOR

Copyright � 11-09-2008 Andy@Portcullis email:tools@portcullis-security.com
New code base dirived from orginal code apache.pl v1.0 by Doc

=cut

=head1 REQUIREMENTS

Perl Libraries: 

* LWP

* IO::Socket

* Parallel::ForkManager

=cut

=head1 LICENSE 

 apache2 - Username Enumeration through Apache UserDir
 Copyright � 2008  Portcullis
 
 This program is free software; you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation; either version 2 of the License, or
 (at your option) any later version.
 
 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.
 
 You should have received a copy of the GNU General Public License along
 with this program; if not, write to the Free Software Foundation, Inc.,
 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

 You are encouraged to send comments, improvements or suggestions to
 me at tools@portcullis-security.com

=cut

use IO::Socket;
use Getopt::Std;
use Parallel::ForkManager;
my %opts;
getopt ("h: l: p: e: s: t:" ,\%opts);
use LWP;


if (!(exists $opts{h})||!(exists $opts{p})||!(exists $opts{l})||!(exists $opts{e})){ &usage;}

sub usage{
print "\nUSAGE: apache.pl [-h 1.2.3.4] [-l names] [-p 80] [-s (SSL Support 1=true 0=false)] [-e 403 (http code)] [-t threads]\n\n ";
exit 1;	
};

if (exists $opts{h}){ 
    $host=$opts{h};
}
if (exists $opts{l}){ 
    $list=$opts{l};
}else {$list="names";}
if (exists $opts{p}){ 
     $port=$opts{p};
}else{$port=80;}
if (exists $opts{e}){ 
     $num=$opts{e};
}else{$num=403;}
if (exists $opts{s}){ 
     $ssl=$opts{s};
}else{$ssl=0;}
if (exists $opts{t}){ 
     $threads=$opts{t};
}else{$threads=1;}

    $main_loop=new Parallel::ForkManager($threads);
    open (LIST, "<$list") or die "Unable to open $list ....$!";
    foreach $name (<LIST>) { 
        $main_loop->start and next;
	chomp $name;
	$page="~".$name.'/';
	if ($ssl==0){
		$url = 'http://'.$host.':'.$port.'/'.$page;
	}else{
		$url = 'https://'.$host.':'.$port.'/'.$page;
	}
	$browser = LWP::UserAgent->new;
	$browser->agent("ApacheUser/2.0");
	$response = $browser->get($url);
	#print $response->status_line."\n";
	if ( $response->status_line =~/($num)/g ) {	  
	    print "$name exists on $host\n";
	}
	$main_loop->finish;
     }
     $main_loop->wait_all_children;
print "Execution time: ". (time - $^T) . " seconds!\n";
close LIST;
exit 1;


