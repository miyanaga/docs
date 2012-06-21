package Docs::ContextMethod;

use strict;
use warnings;
use parent 'Sweets::Code::Binding';

use Any::Moose;

has component => ( is => 'rw', isa => 'Any' );

before run => sub {
    my ( $code, $self, $ctx ) = @_;
    Carp::confess('require Docs::Context as the first argument')
        unless eval { $ctx->isa('Docs::Context') };
};

no Any::Moose;
__PACKAGE__->meta->make_immutable;

1;
__END__
