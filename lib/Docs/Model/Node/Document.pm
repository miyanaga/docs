package Docs::Model::Node::Document;

use strict;
use warnings;
use parent 'Docs::Model::Node';

use Any::Moose;
use Docs;

has formatter => ( is => 'rw', isa => 'Docs::Formatter', lazy_build => 1, builder => sub {
    my $self = shift;
    Docs->app->formatter($self->naming->extension);
});
has metadata => ( is => 'rw', isa => 'Docs::Model::Node::Metadata', lazy_build => 1, builder => sub {
    my $self = shift;
    my $metadata = $self->formatter->metadata($self->source);
    $metadata->node($self);
    $metadata;
});

sub child_class { '' }

sub source {
    my $self = shift;
    my $path = $self->file_path;

    my $source = '';
    if ( -f $path ) {
        open(my $fh, '<:utf8', $path) || Carp::confess("failed to open $path");
        $source = join('', <$fh>);
        close($fh);
    }

    $source;
}

sub formatted_body {
    my $self = shift;
    $self->formatter->format($self->source);
}

sub rebuild {
    my $self = shift;
    $self->books->cancel_rebuild_if;
    $self->SUPER::rebuild;
}

sub ensure {
    my $self = shift;
    my $file = shift || return $self;

    # Document has no children.
    return;
}

sub from_naming {
    my $pkg = shift;
    my ( $naming ) = @_;

    my $app = Docs::app();

    return undef unless $app->formatter($naming->extension);
    $pkg->SUPER::from_naming($naming);
}

no Any::Moose;
__PACKAGE__->meta->make_immutable;

1;
__END__
