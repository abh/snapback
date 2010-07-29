package Snapback::Server;
use Moose;
use AnyEvent::Util qw(run_cmd);
use Snapback::Util qw(ssh_cmd);

use namespace::clean;

has name => (
  isa => 'Str',
  is  => 'rw',
);

has uname => (
  isa => 'Str',
  is  => 'rw',
  default => '',
);

has connection_ok => (
  isa => 'Bool',
  is  => 'rw',
  default => undef,
);

sub check_connection {
    my ($self, $cb) = @_;
    my $cmd = [ ssh_cmd( $self->name, 'uname -a' ) ];
    my $cv = run_cmd($cmd,
                         "<"  => "/dev/null",
                         ">"  => \my $std,
                         "2>" => \my $error,
                         close_all => 1,
                        );
    $cv->cb(sub {
                my $rv = shift->recv;
                chomp $std if $std;
                chomp $error if $error;
                if ($rv) {
                    $self->connection_ok(0);
                }
                else {
                    $self->connection_ok(1);
                    $self->uname($std);
                }
                $cb->( $self->connection_ok, $std, $error );
            }
           );
    return $cv;
}

1;
