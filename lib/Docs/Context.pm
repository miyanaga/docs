package Docs::Context;

use strict;
use warnings;

use Any::Moose;

use Docs::Model::Node::Folder;
use Docs::Model::Node::Document;

has document => ( is => 'rw', isa => 'Docs::Model::Node' );
has folder => ( is => 'rw', isa => 'Docs::Model::Folder' );
has language => ( is => 'rw', isa => 'Str', default => 'en' );
has stash_store => ( is => 'ro', isa => 'HashRef', default => sub { {} } );

sub stash {
    my $self = shift;
    my $store_or_object = scalar shift;
    my ( $key, $value ) = @_;

    my $hash = ( $self->stash_store->{$store_or_object} ||= {} );
    return $hash unless defined $key;
    $hash->{$key} = $value if defined $value;
    $hash->{$key};
}

no Any::Moose;
__PACKAGE__->meta->make_immutable;

1;
__END__
