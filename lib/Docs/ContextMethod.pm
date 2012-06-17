package Docs::ContextMethod;

use strict;
use warnings;
use parent 'Sweets::Code::Binding';

use Carp;

sub pre_run {
    my ( $code, $self, $ctx ) = @_;
    Carp::confess('require Docs::Context as the first argument')
        unless eval { $ctx->isa('Docs::Context') };
}

1;
__END__
