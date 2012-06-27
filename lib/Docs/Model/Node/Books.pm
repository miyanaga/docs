package Docs::Model::Node::Books;

use strict;
use warnings;
use parent 'Docs::Model::Node::Folder';

use File::Spec;
use Docs;
use Docs::Model::Node::Naming;
use Docs::Model::Node::Book;
use Any::Moose;

has system_meta => ( is => 'ro', isa => 'Docs::Model::Node::Metadata', lazy_build => 1, builder => sub {
    my $self = shift;
    my $metadata = Docs::Model::Node::Metadata->new;
    my $app = Docs::app();

    my $meta_yml = File::Spec->catdir( $app->components->core->path, 'config/meta.yml' );
    if ( -f $meta_yml ) {
        $metadata->load_yaml($meta_yml);
    }

    $metadata;
});

has languages => ( is => 'ro', isa => 'ArrayRef', lazy_build => 1, builder => sub {
    my $self = shift;
    my %langs;

    # Sort by usage in books
    my $children = $self->children('uri');
    while ( my ( $key, $b ) = each %$children ) {
        my $point = 1;
        for my $l ( @{$b->languages} ) {
            $langs{$l->key} ||= 0;
            $langs{$l->key} += ( $point /= 2 );
        }
    }

    my @languages = map {
        Docs::app()->language($_);
    } sort {
        $langs{$a} <=> $langs{$b};
    } keys %langs;

    \@languages;
});

sub child_class {
    my $self = shift;
    my ( $file_name, $file_path ) = @_;

    -d $file_path? 'Docs::Model::Node::Book': undef;
}


no Any::Moose;
__PACKAGE__->meta->make_immutable;

1;
__END__
