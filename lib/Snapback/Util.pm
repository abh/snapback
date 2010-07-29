package Snapback::Util;
use strict;
use base qw(Exporter);

our @EXPORT_OK = qw(
   ssh_cmd
);


sub ssh_cmd {
    my ($host, $cmd) = @_;
    return ('ssh', 'root@' . $host, $cmd);
}


1;
