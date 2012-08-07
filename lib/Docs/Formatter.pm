package Docs::Formatter;

use strict;
use warnings;

use Any::Moose;
use Docs::Model::Node::Metadata;

has label => ( is => 'rw', isa => 'Str', default => 'HTML Formatter' );
has args => ( is => 'rw', default => sub { {} } );

sub split {
    my $self = shift;
    my ( $rsource ) = @_;
    my ( $style, $meta, $body ) = ( '', '', '' );

    if ( $$rsource =~ /^\s*\@/ ) {
        $style = 'javadoc';
        ( $meta, $body ) = split( /(?<!\\)\n(?!\s*\@)/, $$rsource, 2 );
    } elsif ( $$rsource =~ /^\s*<!--/ ) {
        $style = 'yaml';
        if ( $$rsource =~ s/\s*<!--(.*?)-->\s*//s ) {
            $body = $$rsource;
            $meta = $1;
        }
    } else {
        $style = '';
        $body = $$rsource;
    }

    ( $style, $meta, $body );
}

sub format {
    my $self = shift;
    my ( $source ) = @_;
    my ( $style, $meta, $body ) = $self->split(\$source);

    # Pass through.
    $body;
}

sub metadata {
    my $self = shift;
    my ( $source ) = @_;
    my ( $style, $meta, $body ) = $self->split(\$source);

    my $metadata = Docs::Model::Node::Metadata->new;
    if ( $style eq 'javadoc' ) {
        $metadata->from_javadoc($meta);
    } elsif ( $style eq 'yaml' ) {
        eval { $metadata->from_yaml($meta) };
    }

    $metadata;
}

no Any::Moose;
__PACKAGE__->meta->make_immutable;

1;
__END__
