package Docs::Model::Node::Book;

use strict;
use warnings;
use parent 'Docs::Model::Node::Folder';

use Any::Moose;

has languages => ( is => 'ro', isa => 'ArrayRef', lazy_build => 1, builder => sub {
    my $self = shift;
    my @langs = $self->metadata->cascade_find([qw/languages langs/])->as_array;

    my $app = Docs::app();
    $langs[0] ||= $app->preferred_lang;
    my @languages = grep { $_ } map { $app->language($_); } @langs;

    \@languages;
});
has preferred_language => ( is => 'ro', isa => 'Str', lazy_build => 1, builder => sub {
    my $self = shift;
    my $languages = $self->languages;

    my $app = Docs::app();
    $languages->[0] || $app->preferred_language;
});

no Any::Moose;
__PACKAGE__->meta->make_immutable;

1;
__END__
