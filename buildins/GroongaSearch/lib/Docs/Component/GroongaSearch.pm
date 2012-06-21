package Docs::Component::GroongaSearch;

use strict;
use warnings;

use Docs;
use Docs::Context;
use Time::HiRes;
use Groonga::Console::Simple::Request;

sub on_node_pre_rebuild {
    my ( $cb, $node ) = @_;
    my $app = Docs::app();

    if ( eval { $node->isa('Docs::Model::Node::Book' ) } ) {
        for my $lang ( @{$node->languages} ) {
            my $ctx = $app->new_context(language => $lang);
            $node->ctx_groonga_migrate($ctx);
        }
    }
}

sub on_node_post_rebuild {
    my ( $cb, $node ) = @_;

    if ( eval { $node->isa('Docs::Model::Node::Document') } ) {
        _on_document_post_rebuild(@_);
    } elsif ( eval { $node->isa('Docs::Model::Node::Book') } ) {
        _on_book_post_rebuild(@_);
    }
}

sub _on_document_post_rebuild {
    my ( $cb, $node ) = @_;
    my $app = Docs::app();
    my $book = $node->book || return;

    for my $lang ( @{$book->languages} ) {
        my $ctx = $app->new_context(language => $lang);
        $node->ctx_groonga_load($ctx);
    }
}

sub _on_book_pre_rebuild {
    my ( $cb, $node ) = @_;
}

sub _on_book_post_rebuild {
    my ( $cb, $node ) = @_;
}

1;
__END__
