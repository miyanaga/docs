package Docs::Model::Node;

use strict;
use warnings;
use utf8;
use parent qw(Sweets::Tree::MultiPath::Node Sweets::Aspect::Stashable::AnyEvent);
$Sweets::Tree::MultiPath::Node::DEFAULT_NS = 'uri';

use Any::Moose;
use Docs;
use Docs::Model::Node::Metadata;
use Docs::Model::Node::Naming;
use Docs::Context;
use File::Spec;

has naming => ( is => 'ro', isa => 'Docs::Model::Node::Naming', lazy_build => 1, builder => sub {
    Docs::Model::Node::Naming->new
});
has metadata => ( is => 'rw', isa => 'Docs::Model::Node::Metadata', lazy_build => 1, builder => sub {
    shift->new_metadata;
});
has books => ( is => 'ro', isa => 'Any', lazy_build => 1, builder => sub {
    shift->parent_at(0) || 0;
});
has book => ( is => 'ro', isa => 'Any', lazy_build => 1, builder => sub {
    shift->parent_at(1) || 0;
});

sub new_metadata {
    my $self = shift;
    my ( $raw ) = @_;
    $raw = {} unless defined $raw;

    my $meta = Docs::Model::Node::Metadata->new( $raw );
    $meta->node($self);

    $meta;
}

sub uri_name { shift->name('uri', @_) }
sub file_name { shift->name('file', @_) }

sub uri_path { shift->build_path('uri', '/') }
sub file_path { shift->build_path('file', '/') }

sub find_uri { shift->find('uri', @_) };
sub find_file { shift->find('file', @_) };

sub path_find {
    my $self = shift;
    my ( $path ) = @_;
    return $self if !defined($path) || $path eq '';
    if ( substr( $path, 0, 1 ) eq '/' ) {
        $self->books->path_find( substr( $path, 1 ) );
    } else {
        $self->find_uri( grep { $_ } split '/', $path );
    }
}

sub is_in_uri_path {
    shift->is_in_path('uri', @_);
}

sub child_class { die 'Must be overridden' }

sub is_document { eval { shift->isa('Docs::Model::Node::Document'); }; }
sub is_folder { eval { shift->isa('Docs::Model::Node::Folder'); }; }
sub is_book { eval { shift->isa('Docs::Model::Node::Book'); }; }
sub is_books { eval { shift->isa('Docs::Model::Node::Books'); }; }
sub is_index { shift->uri_name eq 'index'; }

sub index_node {
    shift->find_uri('index');
}

sub source { '' }

sub formatted_body { '' }

sub file_mtime {
    my $self = shift;
    my $path = $self->file_path;
    -e $path? ( stat $path )[8]: 0;
}

before rebuild => sub {
    my $self = shift;
    my $app = Docs::app();
    $app->callbacks->run_all('node.pre_rebuild', $self);
};

after rebuild => sub {
    my $self = shift;
    my $app = Docs::app();
    $app->callbacks->run_all('node.post_rebuild', $self);
};

sub rebuild {
    my $self = shift;
    my $app = Docs::app();

    $self->clear_metadata;
    $self->clear_stashes;
}

sub ctx_base_href {
    my $self = shift;
    my $ctx = shift;

    my @file_path = File::Spec->splitdir($self->file_path);
    shift @file_path;
    '/' . File::Spec->catdir(@file_path);
}

sub ctx_stash {
    my $self = shift;
    my $ctx = shift;

    $ctx->object_stash( $self, @_ );
}

sub ctx_template {
    my $self = shift;
    my $ctx = shift;

    $self->metadata->ctx_find($ctx, 'template')->as_scalar
        || (
        $self->is_books
            ? 'books'
            : $self->is_book
                ? 'book'
                : 'node'
        );
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
