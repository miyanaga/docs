package Docs::Component::GroongaSearch::HandlerMethod;

use strict;
use warnings;

use Encode;

sub node_search {
    my $self = shift; # node handler
    pop; # original

    my $ctx = $self->context;
    my $node = $ctx->folder;

    my $q = $self->request->parameters->get('q') || '';
    $q = Encode::decode_utf8($q) unless utf8::is_utf8($q);
    my $page = int($self->request->parameters->get('page') || 0) || 0;
    my $per_page = $ctx->search_per_page || 10;
    my $result = $node->ctx_search($ctx, $q, $page, $per_page);

    $self->render('search', q => $q, result => $result);
}

sub node_navigation_tags {
    my $self = shift; # node handler
    pop; # original

    my $ctx = $self->context;
    my @tags = $self->context->book->ctx_navigation_tags($ctx, 'desc');

    # Scaling
    my $max = 1;
    my $limit = 10;
    for my $tag ( @tags ) {
        $max = $tag->node_count if $max < $tag->node_count;
    }

    my $ratio = $max / $limit;
    $ratio = 1 if $ratio < 1;

    for my $tag ( @tags ) {
        my $scale = int($tag->node_count * $ratio);
        $scale = $limit if $scale > $limit;
        $scale = 1 if $scale < 1;
        $tag->scale($scale);
    }

    $self->render('partial/node/tagcloud', tags => \@tags);
}

1;
__END__
