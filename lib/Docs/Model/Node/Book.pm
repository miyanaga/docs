package Docs::Model::Node::Book;

use strict;
use warnings;
use parent 'Docs::Model::Node::Folder';

use Any::Moose;

has languages => ( is => 'ro', isa => 'ArrayRef', lazy_build => 1, builder => sub {
    my $self = shift;
    my @languages = $self->metadata->_cascade_find('languages')->_array;
    $languages[0] ||= 'en';
    \@languages;
});
has preferred_language => ( is => 'ro', isa => 'Str', lazy_build => 1, builder => sub {
    my $languages = shift->languages;
    $languages->[0] || 'en';
});

no Any::Moose;
__PACKAGE__->meta->make_immutable;

1;
__END__
