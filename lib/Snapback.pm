package Snapback;
use strict;
use Moose;

warn "$$ going to run ...";

# load configuration
# count of currently running rsync processes
# start more if running < 2


1;

__END__
my $cmd = [qw(/usr/bin/rsync -aIP dev2.la.sol:public_html /tmp/)];

#$cmd = ['perl', '-e', 'print "foo..\n"'];

my $cv = run_cmd($cmd,
                 "<", "/dev/null",
                 ">" , \my $std,
                 "3>", \my $error,
                 '$$' => \my $pid,
                 on_prepare => sub { warn "$$ preparing" },
                );

my $error  = "";
warn "PID: $pid";

   $cv->cb (sub {
      warn "PID2: $pid";
      shift->recv and warn "rsync failed: $?";

      print "S: $std\nE: $error\n";
   });

# $cv->recv;

AnyEvent->condvar->recv;


warn "$$ done!";



1;
