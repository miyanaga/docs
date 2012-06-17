package Docs::Model::Node::Headline;

use strict;
use warnings;

use Any::Moose;
use Docs::Model::Node;

has node => ( is => 'ro', isa => 'Docs::Model::Node', required => 1 );
has tag => ( is => 'ro', isa => 'Str', required => 1 );
has level => ( is => 'ro', isa => 'Int', lazy_build => 1, builder => sub {
    my $tag = shift->tag;
    if ($tag =~ /^h([1-6])/) {
        return int($1);
    }
    return 0;
});
has text => ( is => 'ro', isa => 'Str', required => 1 );

no Any::Moose;

1;
__END__
