package Docs::ContextMethod::Node;

use strict;
use warnings;

use Docs::Model::Node::Tag;
use Docs::Model::Node::Headline;

sub title {
    my $node = shift;
    my $ctx = shift;

    $node->metadata->_ctx_find($ctx, 'title')->_scalar
        || $node->naming->title;
}

sub author {
    my $node = shift;
    my $ctx = shift;

    $node->metadata->_ctx_cascade_find($ctx, 'author')->_scalar || '';
}

sub body {
    my $node = shift;
    my $ctx = shift;

    my $source = $node->source || return '';

    # Language filter.
    $source =~ s|<lang:([a-z]+)>\s*(.*?)\s*</lang:\1>|{$1 eq $ctx->language? $2: ''}|iges;

    $node->formatter->format($source);
}

sub plain_text {
    my $node = shift;
    my $ctx = shift;

    my $body = $node->ctx_body($ctx);
    $body =~ s!<[^>]*>! !sg;
}

sub plain_text_without_headlines {
    my $node = shift;
    my $ctx = shift;

    my $body = $node->ctx_body($ctx);
    $body =~ s!<(h[1-6])(?:.*?)>(.+?)</\1>!!isg;
    $body =~ s!<[^>]*>! !sg;

    $body;
}

sub headlines {
    my $node = shift;
    my $ctx = shift;

    my $html = $node->ctx_body($ctx);
    my @headlines;
    while ( $html =~ m!<(h[1-6])(?:.*?)>(.+?)</\1>!isg ) {
        my $h = Docs::Model::Node::Headline->new(
            node    => $node,
            tag     => $1,
            text    => $2,
        );
        push @headlines, $h;
    }

    return wantarray? @headlines: \@headlines;
}

sub raw_tags {
    my $node = shift;
    my $ctx = shift;

    my @tags = $node->metadata->_ctx_find($ctx, 'tags')->_array;
    wantarray? @tags: \@tags;
}

sub tags {
    my $node = shift;
    my $ctx = shift;

    my @tags = map { Docs::Model::Node::Tag->new(
        node => $node,
        raw => $_
    ) } @{$node->ctx_raw_tags($ctx)};

    wantarray? @tags: \@tags;
}

sub normalize {
    my $node = shift;
    my $ctx = shift;
    my $original = pop;
    my $methods = shift;
    my $depth = shift;

    my %hash;
    for my $m ( @$methods ) {
        if ( $node->can($m) ) {
            $hash{$m} = $node->$m( $ctx, @_ );
        }
    }

    $depth-- if defined $depth;
    if ( !defined($depth) || $depth >= 0 ) {
        my %children;
        my $children = $node->children('uri');
        while ( my ( $uri, $child ) = each %$children ) {
            $children{$uri} = $child->ctx_normalize( $ctx, $methods, $depth, @_ );
        }
        $hash{children} = \%children;
    }

    \%hash;
}

1;
__END__
