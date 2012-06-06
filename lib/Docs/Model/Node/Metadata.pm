package Docs::Model::Node::Metadata;

use strict;
use warnings;
use parent 'Sweets::Variant::Cascading';

use Any::Moose;

has 'node' => ( is => 'rw', isa => 'Docs::Model::Node' );

sub _cascade_to {
    shift->node->parent->metadata;
}

no Any::Moose;
__PACKAGE__->meta->make_immutable;

1;
__END__
