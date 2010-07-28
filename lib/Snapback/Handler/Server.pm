package Snapback::Handler::Server;
use strict;
use base qw(Snapback::Handler);
__PACKAGE__->asynchronous(1);

use Time::HiRes ();

sub get { shift->post(@_) }

sub post {
    my $self = shift;

    # check if it's there already
    # add to configuration?

    my $server_name = $self->request->param('server');

    unless ($server_name) {
        $self->write({ success => 0,
                       type => 'mount',
                       status => 'No server' });
        $self->finish;
    }

    my $mq = Tatsumaki::MessageQueue->instance('snapback');
    $mq->publish({
                  type => "mount",
                  status => "Getting mounts from $server_name",
                  time => scalar Time::HiRes::gettimeofday,
                 });

    $self->app->update_mounts
      ($server_name,
       sub {
           my $mounts = shift;
           warn "got mounts";

           $mq->publish({
                         type => "mount",
                         time => scalar Time::HiRes::gettimeofday,
                         status => 'Updated mounts',
                         server => { name   => $server_name,
                                     mounts => $mounts,
                                   },
                        });
       }
      );

}
1;
