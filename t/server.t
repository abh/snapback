use Test::More;
use strict;

use_ok('Snapback::Server');

# TODO: get hostname from environment variable;
#   skip tests if it's not set

my $hostname = 'dev2';

ok(my $s = Snapback::Server->new(name => $hostname), 'new object');
is($s->connection_ok, undef, 'connection not yet checked');
ok( my $cv = $s->check_connection(
        sub {
            my $ok = shift;
            ok($ok, 'connection check returned ok');
        }
    ),
    'checking connection'
);
$cv->recv; # wait for ssh connection to finish

is($s->connection_ok, 1, 'connection got marked ok');
ok($s->uname, 'has uname');

done_testing;
