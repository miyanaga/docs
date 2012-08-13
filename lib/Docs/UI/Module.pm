package Docs::UI::Module;

use strict;
use warnings;

use Any::Moose;
use parent 'Docs::Template';

has name => ( is => 'ro', isa => 'Str', required => 1 );
has include_paths => ( is => 'ro', isa => 'ArrayRef', lazy => 1, default => sub {
    Docs::app()->components->dir_paths_to('modules'),
});

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

    $self->SUPER::render( $ctx, $self->name, \%args );
}

no Any::Moose;
__PACKAGE__->meta->make_immutable;

1;
__END__
