package Docs::Model::Node::Tag;

use strict;
use warnings;

use Any::Moose;
use Docs::Model::Node;

has node => ( is => 'ro', isa => 'Docs::Model::Node', required => 1);
has raw => ( is => 'ro', isa => 'Str', required => 1 );
has group => ( is => 'rw', isa => 'Str', lazy_build => 1, builder => sub {
    my ( $group, $label ) = shift->parse;
    $group || '';
});
has label => ( is => 'rw', isa => 'Str', lazy_build => 1, builder => sub {
    my ( $group, $label ) = shift->parse;
    $label;
});
has full_path => ( is => 'rw', isa => 'Str', lazy_build => 1, builder => sub {
    my $self = shift;
    my $book = $self->node->book || return $self->raw;
    join('/', $book->uri_name, $self->raw);
});

sub parse {
    my ( $group, $label ) = split(':', shift->raw);
    unless ($label) {
        $label = $group;
        $group = '';
    }
    ( $group, $label );
}

no Any::Moose;

1;
__END__
