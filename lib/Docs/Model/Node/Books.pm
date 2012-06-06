package Docs::Model::Node::Books;

use strict;
use warnings;
use parent 'Docs::Model::Node::Folder';

use File::Spec;
use Docs;
use Docs::Model::Util::NodeName;
use Docs::Model::Node::Book;
use Any::Moose;

sub child_class {
    my $self = shift;
    my ( $file_name, $file_path ) = @_;

    -d $file_path? 'Docs::Model::Node::Book': undef;
}

no Any::Moose;
__PACKAGE__->meta->make_immutable;

1;
__END__
