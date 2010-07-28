package Snapback::Handler::Main;
use strict;
use base qw(Snapback::Handler);
use Digest::SHA qw(sha1_hex);

use namespace::clean;

sub get {
    my $self = shift;
    if (!$self->request->cookies->{sid}) {
        $self->response->cookies->{sid} = { value => sha1_hex(time . rand . rand),
                                            path  => '/',
                                          };
    }
    $self->render('index.html');
    $self->finish;
}


1;
