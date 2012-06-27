package Docs::Application::Handler::Test;

use strict;
use warnings;
use parent 'Docs::Application::Handler';

use Docs;

sub get {
    my $self = shift;
    my ( $test ) = @_;
    $test ||= '';
    $test =~ s/^.+(::|\/)//g;

    if ( $self->can($test) ) {
        $self->$test;
    } else {
        $self->write('unknown test');
    }
}

sub echo {
    my $self = shift;
    $self->write($self->request->param('echo'));
}

sub path_info {
    my $self = shift;
    $self->write($self->request->path_info);
}

1;
