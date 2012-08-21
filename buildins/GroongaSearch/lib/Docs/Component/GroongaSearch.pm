package Docs::Component::GroongaSearch;

use strict;
use warnings;

use Docs;
use Docs::Context;
use Time::HiRes;
use Groonga::Console::Simple::Request;

sub on_node_pre_rebuild {
    my ( $cb, $node ) = @_;
    return if $node->is_books;
    $node->books->cancel_rebuild_if;

    my $app = Docs::app();
    if ( $node->is_book ) {
        for my $l ( @{$node->languages} ) {
            my $ctx = $app->new_context(lang => $l->key);
            $node->ctx_groonga_migrate($ctx);
        }
    }
}

sub on_node_post_rebuild {
    my ( $cb, $node ) = @_;
    return if $node->is_books;
    $node->books->cancel_rebuild_if;

    my $app = Docs::app();
    if ( $node->is_book ) {
        for my $l ( @{$node->languages} ) {
            my $ctx = $app->new_context(lang => $l->key);
            $node->ctx_groonga_cleanup($ctx);
        }
    } elsif ( $node->is_folder || $node->is_document ) {
        my $book = $node->book;
        for my $l ( @{$book->languages} ) {
            my $ctx = $app->new_context(lang => $l->key);
            $node->ctx_groonga_load($ctx);
        }
    }
}

1;
__END__
