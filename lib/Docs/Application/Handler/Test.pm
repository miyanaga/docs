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

sub config {
    my $self = shift;

    use Data::Dumper;
    $self->write(Dumper(Docs->app->config));
}



1;
