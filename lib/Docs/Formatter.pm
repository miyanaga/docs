package Docs::Formatter;

use strict;
use warnings;

use Any::Moose;
use Docs::Model::Node::Metadata;

has label => ( is => 'rw', isa => 'Str', default => 'Unknown Formatter' );
has args => ( is => 'rw', default => sub { {} } );

sub format {
    my $self = shift;
    my ( $source ) = @_;

    # Remove header comment.
    $source =~ s/^\s*<!--(.*?)-->\n*//s;

    # Pass through.
    $source;
}

sub metadata {
    my $self = shift;
    my ( $source ) = @_;

    # Header comment.
    my $meta = Docs::Model::Node::Metadata->new;
    if ( $source =~ s/^\s*<!--(.*?)-->\n*//s ) {
        my $yaml = $1;
        eval { $meta->_from_yaml($yaml) };
    }

    $meta;
}

no Any::Moose;
__PACKAGE__->meta->make_immutable;

1;
__END__
