package Docs::Model::Node::Folder;

use strict;
use warnings;
use parent 'Docs::Model::Node';

use Any::Moose;
use File::Spec;
use Docs::Model::Node::Document;
use Docs::Model::Node::Naming;
use YAML::Syck;
use Encode;

$YAML::Syck::ImplicitUnicode = 1;

has metadata => ( is => 'rw', isa => 'Docs::Model::Node::Metadata', lazy_build => 1, builder => sub {
    my $self = shift;
    my $metadata = Docs::Model::Node::Metadata->new;

    my $meta_yml = File::Spec->catdir( $self->file_path, 'meta.yml' );
    if ( -f $meta_yml ) {
        $metadata->load_yaml($meta_yml);
    }

    $metadata->node($self);
    $metadata;
});

sub child_class {
    my $self = shift;
    my ( $file_name, $file_path ) = @_;

    -d $file_path
        ? 'Docs::Model::Node::Folder'
        : -f $file_path
            ? 'Docs::Model::Node::Document'
            : undef;
}

sub rebuild {
    my $self = shift;

    $self->SUPER::rebuild;

    my $app = Docs::app();
    opendir(my $dh, $self->file_path) || return;
    while( my $entry = readdir($dh) ) {
        $entry = Encode::decode_utf8($entry) unless utf8::is_utf8($entry);

        next if $entry =~ /^\./;
        my $path = File::Spec->catdir($self->file_path, $entry);
        my $pkg = $self->child_class($entry, $path) || next;

        if ( my $naming = Docs::Model::Node::Naming->parse($entry) ) {

            # TODO: Node name error handling.
            my $child = $pkg->from_naming($naming) || next;

            $self->add($child);
            $child->rebuild;
        }
    }
    closedir($dh);
}

sub ensure {
    my $self = shift;
    my $file = shift || return $self;

    my $child = $self->find_file($file);
    unless($child) {
        my $path = File::Spec->catdir($self->file_path, $file);
        my $pkg = $self->child_class($file, $path) || return;

        my $naming = Docs::Model::Node::Naming->parse($file) || return;
        $child = $pkg->from_naming($naming) || next;
        $self->add($child);
        $child->rebuild;
    }

    $child->ensure(@_);
}

no Any::Moose;
__PACKAGE__->meta->make_immutable;

1;
__END__
