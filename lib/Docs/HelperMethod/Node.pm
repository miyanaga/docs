package Docs::HelperMethod::Node;

use strict;
use warnings;

use Carp;

sub link_to_node {
    my $self = shift;
    my $node = shift || return '[Unknown Node]';
    pop;
    my %args = @_;
    my $ctx = $self->context;
    my $numbering = 1;
    $numbering = 0 if $args{nonumbering};
    my $tags = $args{tags};

    $args{inner} = $numbering
        ? join( '', '<span class="docs-numbering">', $node->ctx_numbering($ctx), '</span> <span class="docs-node-title">' , $node->ctx_title($ctx), '</span>' )
        : $node->ctx_title($ctx);

    if ($tags) {
        for my $tag ( $node->ctx_tags($ctx) ) {
            $args{inner} .= ' ' . $self->link_to_tag($tag, nolink => 1);
        }
    }

    delete $args{attr}->{href} if $args{attr};
    $args{raw_attr} ||= {};
    $args{raw_attr}->{href} = $node->normalized_uri_path;
    $args{raw_attr}->{href} .= '#' . delete $args{hash} if $args{hash};

    $self->element('a', %args);
}

sub link_to_tag {
    my $self = shift;
    my $tag = shift || return '[Unknown Tag]';
    pop;
    my %args = @_;

    my $book = $tag->node
        ? $tag->node->book
        : $self->context->book;

    Carp::confess('link_to_tag requires book context')
        unless $book;

    my $classes = $self->stash('tag_group_classes');
    unless ( $classes ) {
        $classes = $book->metadata->cascade_set('tag_group_classes')->merge_hashes;
        $self->stash('tag_group_classes', $classes);
    }

    my @class;
    if ( my $all = $classes->find('_all')->as_array ) {
        push @class, @$all;
    }
    if ( $tag->group ) {
        if ( my $group = $classes->find($tag->group)->as_array ) {
            push @class, @$group;
        }
    }

    $args{inner} ||= $tag->label;

    $args{class} ||= '';
    $args{class} = join(' ', @{$args{class}}) if ref $args{class} eq 'ARRAY';
    $args{class} .= ' ' if $args{class};
    $args{class} .= join(' ', @class);

    my $tag_name = 'a';
    if ($args{nolink}) {
        $tag_name = 'span';
    } else {
        delete $args{attr}->{href};
        $args{raw_attr} ||= {};
        $args{raw_attr}->{href} = $self->node_action($book, 'search', { q => 'tag:' . $tag->raw });
    }

    $self->element($tag_name, %args);
}

1;
__END__
