package Docs::Model::Node;

use strict;
use warnings;
use parent 'Sweets::Tree::MultiPath::Node';
$Sweets::Tree::MultiPath::Node::DEFAULT_NS = 'uri';

use Any::Moose;
use Docs::Model::Node::Metadata;
use Docs::Model::Node::Naming;

has naming => ( is => 'ro', isa => 'Docs::Model::Node::Naming', lazy_build => 1, builder => sub {
    Docs::Model::Node::Naming->new
});
has metadata => ( is => 'rw', isa => 'Docs::Model::Node::Metadata', lazy_build => 1, builder => sub {
    my $self = shift;
    my $metadata = Docs::Model::Node::Metadata->new( node => $self );
    $metadata;
});
has books => ( is => 'ro', isa => 'Any', lazy_build => 1, builder => sub {
    shift->parent_at(0) || 0;
});
has book => ( is => 'ro', isa => 'Any', lazy_build => 1, builder => sub {
    shift->parent_at(1) || 0;
});
has temporary => ( is => 'ro', isa => 'HashRef', lazy_build => 1, builder => sub { {} } );

sub is_folder { 0 };

sub uri_name { shift->name('uri', @_) }
sub file_name { shift->name('file', @_) }

sub uri_path { shift->build_path('uri', '/') }
sub file_path { shift->build_path('file', '/') }

sub find_uri { shift->find('uri', @_) };
sub find_file { shift->find('file', @_) };

sub child_class { die 'Must be overridden' }

sub source { '' }

sub file_mtime {
    my $self = shift;
    my $path = $self->file_path;
    -e $path? ( stat $path )[8]: 0;
}

sub rebuild {
    my $self = shift;
    $self->clear_metadata;
    $self->clear_temporary;
}

sub ensure { return undef; }

sub from_naming {
    my $pkg = shift;
    my ( $naming ) = @_;

    my $self = $pkg->new(
        naming   => $naming,
    );
    $self->file_name($naming->file);
    $self->uri_name($naming->name);
    $self->order($naming->order) if $naming->order;

    $self;
}

no Any::Moose;
__PACKAGE__->meta->make_immutable;

1;
__END__
