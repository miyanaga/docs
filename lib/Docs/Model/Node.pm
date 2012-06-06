package Docs::Model::Node;

use strict;
use warnings;
use parent 'Sweets::Tree::MultiPath::Node';

use Any::Moose;
use Docs::Model::Node::Metadata;
use Docs::Model::Util::NodeName;

BEGIN {
    $Sweets::Tree::MultiPath::Node::DEFAULT_NS = 'uri';
}

has node_name => ( isa => 'ro', isa => 'Docs::Model::Util::NodeName', lazy_build => 1, builder => sub {
    Docs::Model::Util::NodeName->new
}, handles => [qw/title language extension/]);
has metadata => ( is => 'rw', isa => 'Docs::Model::Node::Metadata', lazy_build => 1, builder => sub {
    my $self = shift;
    my $metadata = Docs::Model::Node::Metadata->new( node => $self );
    $metadata;
});

sub uri_name { shift->name('uri', @_) }
sub file_name { shift->name('file', @_) }

sub uri_path { shift->build_path('uri', '/') }
sub file_path { shift->build_path('file', '/') }

sub find_uri { shift->find('uri', @_) };
sub find_file { shift->find('file', @_) };

sub child_class { die 'Must be overridden' }

sub rebuild {
    my $self = shift;
    $self->clear_metadata;
}

sub ensure { return undef; }

sub from_node_name {
    my $pkg = shift;
    my ( $nn ) = @_;

    my $self = $pkg->new(
        node_name   => $nn,
    );
    $self->file_name($nn->file);
    $self->uri_name($nn->name);
    $self->order($nn->order) if $nn->order;

    $self;
}

no Any::Moose;
__PACKAGE__->meta->make_immutable;

1;
__END__
