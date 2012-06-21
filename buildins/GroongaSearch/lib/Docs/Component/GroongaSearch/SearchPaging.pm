package Docs::Component::GroongaSearch::SearchPaging;

use strict;
use warnings;

use Any::Moose;

has per_page => ( is => 'ro', isa => 'Int', required => 1 );
has page => ( is => 'ro', isa => 'Int', required => 1 );
has offset => ( is => 'ro', isa => 'Int', lazy_build => 1, builder => sub {
    my $self = shift;
    $self->per_page * $self->normalized_page;
});
has limit => ( is => 'ro', isa => 'Int', lazy_build => 1, builder => sub {
    my $self = shift;
    $self->per_page * ( $self->normalized_page + 1 );
});

sub normailzed_page {
    my $self = shift;
    my $page = $self->page;
    $page < 0? 0: $page;
}

no Any::Moose;
__PACKAGE__->meta->make_immutable;

1;
__END__
