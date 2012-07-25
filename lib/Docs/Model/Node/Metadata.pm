package Docs::Model::Node::Metadata;

use strict;
use warnings;
use parent 'Sweets::Variant::Cascading';

use Any::Moose;

has node => ( is => 'rw', isa => 'Docs::Model::Node' );

sub cascade_to {
    my $self = shift;
    my $node = $self->node || return;
    my $parent = $node->parent;
    return $node->system_meta unless $parent;
    $parent->metadata;
}

sub ctx_find {
    my $self = shift;
    my $ctx = shift;

    my $last = pop;
    $last = [ join('.', $last, $ctx->language->key), $last ] unless ref $last;

    $self->SUPER::find( @_, $last );
}

sub ctx_cascade_find {
    my $self = shift;
    my $ctx = shift;

    my $last = pop;
    $last = [ join('.', $last, $ctx->language->key), $last ] unless ref $last;

    $self->SUPER::cascade_find( @_, $last );
}

sub ctx_cascade_set {
    my $self = shift;
    my $ctx = shift;

    my $last = pop;
    $last = [ join('.', $last, $ctx->language->key), $last ] unless ref $last;

    $self->SUPER::cascade_set( @_, $last );
}

no Any::Moose;
__PACKAGE__->meta->make_immutable;

1;
__END__
