package Docs::HelperMethod::Node;

use strict;
use warnings;

use Carp;

sub link_to_node {
    my $self = shift;
    my $node = shift;
    pop;
    my %args = @_;
    my $ctx = $self->context;
    my $numbering = 1;
    $numbering = 0 if $args{nonumbering};

    $args{inner} = $numbering
        ? join( ' ', $node->ctx_numbering($ctx) , $node->ctx_title($ctx) )
        : $node->ctx_title($ctx);

    delete $args{attr}->{href} if $args{attr};
    $args{raw_attr} ||= {};
    $args{raw_attr}->{href} = $node->ctx_url($ctx);

    $self->element('a', %args);
}

sub link_to_tag {
    my $self = shift;
    my $tag = shift;
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
