package Snapback::Application;
use Tatsumaki;
use Tatsumaki::Error;
use Tatsumaki::Application;
use base qw(Tatsumaki::Application);
use Moose;
use File::Basename qw(dirname);
use Snapback::Handler::Main;
use Snapback::Handler::Server;
use Snapback::Handler::Poll;
use Snapback::Mounts;
use AnyEvent;
use AnyEvent::Util qw(run_cmd);

use namespace::clean;

around BUILDARGS => sub {
    my $orig = shift;
    my $class = shift;

    return $class->$orig(['/' => 'Snapback::Handler::Main', 
                          '/server/.*' => 'Snapback::Handler::Server',
                          '/poll' => 'Snapback::Handler::Poll',
                          @_]);
};

sub BUILD {
    my $app = shift;
    $app->template_path(dirname(__FILE__) . "/../../templates");
    $app->static_path(dirname(__FILE__) . "/../../static");
    warn "Added paths ...: ", $app->static_path;

}

has testing => (
    is  => 'rw',
    isa => 'Bool',
    default => 0,
);

sub _ssh_command {
    my ($host, $cmd) = @_;
    return ('ssh', 'root@' . $host, $cmd);
}

sub update_mounts {
    my ($self, $host, $cb) = @_;

    my $std;
    if ($self->testing) {
        warn "is testing";

        $std = '/dev/mapper/vg0-root on / type ext3 (rw,noatime)
proc on /proc type proc (rw)
sysfs on /sys type sysfs (rw)
devpts on /dev/pts type devpts (rw,gid=5,mode=620)
/dev/mapper/vg0-home on /home type ext3 (rw,noatime,usrquota)
/dev/mapper/vg0-var on /var type ext3 (rw,noatime)
/dev/mapper/vg0-pkg on /pkg type ext3 (rw,noatime)
/dev/mapper/vg0-usr on /usr type ext3 (rw,noatime)
/dev/xvda1 on /boot type ext3 (rw)
tmpfs on /dev/shm type tmpfs (rw)
/dev/mapper/vg0-local on /local type ext3 (rw,noatime,usrquota)
/dev/mapper/vg0-mogdata on /var/mogdata type ext3 (rw,noatime)
/dev/mapper/vg0-tmp on /tmp type ext3 (rw,noatime)
none on /proc/sys/fs/binfmt_misc type binfmt_misc (rw)
sunrpc on /var/lib/nfs/rpc_pipefs type rpc_pipefs (rw)';

        my $w; $w = AnyEvent->timer(after => 1,
                                 cb => sub { 
                                     undef $w;
                                     my $mounts = Snapback::Mounts::parse_mounts($std);
                                     $cb->( $mounts )
                                 });

        return;
    }

    my $cmd = [ _ssh_command( $host, 'mount' ) ];
    my $cv = run_cmd($cmd,
                         "<", "/dev/null",
                         ">" , \$std,
                         "3>", \my $error,
                        );
    $cv->cb(sub {
                warn "MOUNTS: $std\n";
                my $mounts = Snapback::Mounts::parse_mounts($std);
                $cb->( $mounts );
            }
           );

}

1;
