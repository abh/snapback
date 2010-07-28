package Snapback::Handler::Poll;
use strict;
use base qw(Snapback::Handler);
use Tatsumaki::MessageQueue;
__PACKAGE__->asynchronous(1);

sub get {
    my $self = shift;
    my $mq = Tatsumaki::MessageQueue->instance('snapback');
    my $client_id = $self->request->param('client_id')
      or Tatsumaki::Error::HTTP->throw(500, "'client_id' needed");
    warn "polling snapback queue";
    $mq->poll_once($client_id, sub { $self->on_new_event(@_) });
}

sub on_new_event {
    my($self, @events) = @_;
    $self->write(\@events);
    $self->finish;
}


1;
