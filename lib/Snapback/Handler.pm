package Snapback::Handler;
use strict;
use base qw(Tatsumaki::Handler);

sub app { shift->application(@_) }

1;
