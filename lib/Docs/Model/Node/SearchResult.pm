package Docs::Model::Node::SearchResult;

use strict;
use warnings;
use parent 'Sweets::Pager::Result';

use Any::Moose;

has search_type => ( is => 'rw', isa => 'Str' );
has q => ( is => 'rw', isa => 'Str' );
has search_keyword => ( is => 'rw', isa => 'Str' );
has search_tag => ( is => 'rw', isa => 'Docs::Model::Node::Tag' );

no Any::Moose;
__PACKAGE__->meta->make_immutable;


package Docs::Model::Node::SearchRequest;

use strict;
use warnings;
use parent 'Sweets::Pager::Request';

1;
__END__
