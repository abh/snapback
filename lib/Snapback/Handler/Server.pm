package Snapback::Handler::Server;
use strict;
use base qw(Snapback::Handler);
__PACKAGE__->asynchronous(1);
use Snapback::Server;

use Time::HiRes ();

sub get {
    my $self = shift;
    if ($self->request->param('list')) {
        my $db      = $self->app->db;
        my $scope   = $db->new_scope;
        my @entries = $db->root_set->all;
        $self->write(
            [   map { +{name => $_->name, connection_ok => $_->connection_ok} }
                  @entries
            ]
        );
        $self->finish;
    }
}

sub post {
    my $self = shift;

    # check if it's there already
    # add to configuration?

    my $server_name = $self->request->param('server');

    unless ($server_name) {
        $self->write({ success => 0,
                       status => 'No server parameter' });
        $self->finish;
    }

    # TODO: check if the server already exists...

    my $db = $self->app->db;
    my $scope = $db->new_scope;

    my $server = Snapback::Server->new(name => $server_name);
    $db->store( $server_name => $server );
    

    my $mq = Tatsumaki::MessageQueue->instance('log');
    $mq->publish({
                  type => "log",
                  status => "Checking connection to $server_name",
                  time => scalar Time::HiRes::gettimeofday,
                 });

    $server->check_connection(
        sub {
            my $ok = shift;
            my $ok_msg = $ok ? "ok" : "not ok";

            my $scope = $db->new_scope;
            $db->store($server);

            $mq->publish(
                {   type   => "log",
                    time   => scalar Time::HiRes::gettimeofday,
                    status => "Connection to ". $server->name . " was $ok_msg",
                }
            );

            $self->write(
                {   success => $ok,
                    status  => "Connection check to " . $server->name . " (" . $server->uname . ")",
                }
            );
            $self->finish;

        }
    );

}
1;
