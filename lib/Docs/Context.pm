package Docs::Context;

use strict;
use warnings;

use Any::Moose;

use Docs::Model::Node::Folder;
use Docs::Model::Node::Document;

has document => ( is => 'rw', isa => 'Docs::Model::Node' );
has folder => ( is => 'rw', isa => 'Docs::Model::Folder' );
has language => ( is => 'rw', isa => 'Str', default => 'en' );

no Any::Moose;
__PACKAGE__->meta->make_immutable;

1;
__END__
