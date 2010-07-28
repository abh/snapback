#!/usr/bin/env perl
use strict;
use warnings;
use lib 'lib';
use Snapback;
use Data::Dump qw(pp);
use Snapback::Application;

# my $sb = Snapback->new;

#0 && $sb->update_mounts( 'dev2.la.sol',
#                    sub { pp(shift); 
#                          #$cv->send();
#                      }
#               );

package main;
my $app = Snapback::Application->new();
warn "started app: $app";
return $app;

__END__

use Twiggy::Server;
my $server = Twiggy::Server->new(
      host => '127.0.0.1',
      port => 8080,
  );
$server->register_service($app);

my $cv = AnyEvent->condvar;
$cv->recv;



1;
