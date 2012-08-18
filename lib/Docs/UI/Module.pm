package Docs::UI::Module;

use strict;
use warnings;

use Any::Moose;
use parent 'Docs::UI';

has file => ( is => 'ro', isa => 'Str', required => 1 );

sub render {
    my $self = shift;
    my $ctx = shift;
    my $node = shift;
    my $attrs = shift;
    my $values = shift;

    my %args = (
        attributes => $attrs,
        values => $values,
        node => $node,
        formatter => $node->formatter,
    );

    $self->ctx_render( $ctx, 'modules/' . $self->file, \%args, @_ );
}

no Any::Moose;
__PACKAGE__->meta->make_immutable;

1;
__END__
