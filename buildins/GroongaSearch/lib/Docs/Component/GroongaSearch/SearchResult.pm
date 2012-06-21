package Docs::Component::GroongaSearch::SearchResult;

use strict;
use warnings;

use Any::Moose;
use Docs::Model::Node;

has node => ( is => 'ro', isa => 'Docs::Model::Node', required => 1, handles => qr/./ );
has _score => ( is => 'ro', isa => 'Any' );
has _title => ( is => 'ro', isa => 'Str' );
has _lead => ( is => 'ro', isa => 'Str' );
has _headlines => ( is => 'ro', isa => 'ArrayRef' );

no Any::Moose;
__PACKAGE__->meta->make_immutable;

1;
__END__
