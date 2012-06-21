use strict;
use warnings;

use Test::More;
use Docs;

my $app = Docs::app;
my $books = $app->books;
my $book = $books->find_uri('example');
my $folder = $book->find_uri('groonga');

{
    my $ctx = $app->new_context(language => 'en');
    my $result = $folder->ctx_search_node($ctx, 'document');

    is $result->count, 2;

    my $first = $result->data->[0];
    is $first->ctx_title($ctx), 'English';
    is $first->ctx_stash_title($ctx), 'English';
    like $first->ctx_stash_text($ctx), qr(english document);
    is $first->ctx_stash_headlines($ctx)->[0], 'English Document';

    my $second = $result->data->[1];
    is $second->ctx_title($ctx), 'InFolder';
    is $second->ctx_stash_title($ctx), 'InFolder';
    like $second->ctx_stash_text($ctx), qr(document is in folder);
    is $second->ctx_stash_headlines($ctx)->[0], 'In Folder';
}

{
    my $ctx = $app->new_context(language => 'ja');

    my $keyword = 'ドキュメント';
    utf8::decode($keyword);
    my $result = $folder->ctx_search_node($ctx, $keyword);

    is $result->count, 2;

    my $first = $result->data->[0];
    is $first->ctx_title($ctx), 'Japanese';
    is $first->ctx_stash_title($ctx), 'Japanese';
    like $first->ctx_stash_text($ctx), qr(日本語のドキュメント);
    is $first->ctx_stash_headlines($ctx)->[0], '日本語ドキュメント';

    my $second = $result->data->[1];
    is $second->ctx_title($ctx), 'InFolder';
    is $second->ctx_stash_title($ctx), 'InFolder';
    like $second->ctx_stash_text($ctx), qr(フォルダ内にあります);
    is $second->ctx_stash_headlines($ctx)->[0], 'フォルダ内';
}

{
    my $ctx = $app->new_context(langauge => 'en');

    my $result = $folder->ctx_search_node($ctx, 'tag:en');
    is $result->count, 1;

    is $result->data->[0]->uri_path, '/example/groonga/en';
}

{
    my $ctx = $app->new_context(langauge => 'ja');

    my $tag = 'tag:言語:日本語';
    utf8::decode($tag);
    my $result = $folder->ctx_search_node($ctx, $tag);
    is $result->count, 2;
}

{
    my $ctx = $app->new_context(language => 'en');

    my $result = $folder->ctx_navigation_tags($ctx, 'desc');

    is scalar @{$result}, 10;
    is $result->[0]->label, 'document';
    is $result->[0]->node_count, 3;
}

{
    my $ctx = $app->new_context(language => 'en');

    my $result = $folder->ctx_navigation_recent($ctx);

    my @paths = map { $_->uri_path } @$result;
    is_deeply \@paths, [qw(/example/groonga/folder/index /example/groonga/en /example/groonga/ja)];
}

done_testing;
