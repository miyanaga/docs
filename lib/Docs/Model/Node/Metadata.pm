package Docs::Model::Node::Metadata;

use strict;
use warnings;
use parent 'Sweets::Variant::Cascading';

use Any::Moose;

has 'node' => ( is => 'rw', isa => 'Docs::Model::Node' );

sub _cascade_to {
    my $node = shift->node || return;
    my $parent = $node->parent || return;
    $parent->metadata;
}

sub _ctx_find {
    my $self = shift;
    my $ctx = shift;

    my $last = pop;
    $last = [ join('.', $last, $ctx->language), $last ] unless ref $last;
    $self->SUPER::_find( @_, $last );
}

sub _ctx_cascade_find {
    my $self = shift;
    my $ctx = shift;

    my $last = pop;
    $last = [ join('.', $last, $ctx->language), $last ] unless ref $last;
    $self->SUPER::_cascade_find( @_, $last );
}

no Any::Moose;
__PACKAGE__->meta->make_immutable;

1;
__END__
