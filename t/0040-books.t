use strict;
use warnings;

use Test::More;
use Docs;

my $app = Docs::app;

my $books = $app->books;

{
    ok $books;
    is $books->uri_name, '';
    is $books->file_name, 'private/books';
}

my $book = $books->find_uri('example');

{
    ok $book;
    is $book->file_name, 'Example@example';
    is $book->uri_name, 'example';
    is $book->title, 'Example';

    my @children = values %{$book->children('uri')};
    is scalar @children, 2;
}

my $en = $book->find_uri('en');

{
    ok $en;
    is $en->file_name, '01-English@en';
    is $en->uri_name, 'en';
    is $en->title, 'English';
    is $en->order, 1;

    my @children = values %{$en->children('uri')};
    is scalar @children, 4;
}

my $ja = $book->find_uri('ja');

{
    ok $ja;
    is $ja->file_name, '02-日本語@ja';
    is $ja->uri_name, 'ja';
    is $ja->title, '日本語';
    is $ja->order, 2;
}

{
    my $md = $en->find_uri('formatters', 'mddoc');
    ok $md;
    is $md->file_name, '02-MarkdownDocument@mddoc.md';
    is $md->title, 'MarkdownDocument';
    is $md->uri_name, 'mddoc';
    is $md->extension, 'md';
    is $md->order, 2;
}

{
    my $folder = $en->find_uri(q/meta/);
    ok $folder;

    is $folder->metadata->title->_scalar, 'Metadata Testing';
    is $folder->metadata->_find('title.ja')->_scalar, 'メタデータテスト';
    is $folder->metadata->_find('tags')->_scalar, 'meta,folder,test';
    is $folder->metadata->_cascade_find('author')->_scalar, 'The Author';
}

{
    my $doc = $en->find_uri(qw/meta docmeta/);
    ok $doc;

    is $doc->metadata->title->_scalar, 'Document Has Meta';
    is $doc->metadata->_find('title.ja')->_scalar, 'メタデータ付きドキュメント';
    is $doc->metadata->_find('tags')->_scalar, 'meta,document,test';
    is $doc->metadata->_cascade_find('author')->_scalar, 'The Author';
    is $doc->body, qq{<h1>Document Has Meta</h1>

<p>HTML comment at document head means document meta data.</p>
};
}

{
    my $undef = $en->find_uri(qw/not found/);
    is $undef, undef;
}

{
    my $folder = $books->ensure(qw/Example@example 01-English@en 01-Formatters@formatters/);
    ok $folder;
    is $folder->title, 'Formatters';

    my $doc = $books->ensure(qw/Example@example 01-English@en 01-Formatters@formatters 01-HTMLDocument@htmldoc.html/);
    ok $doc;
    is $doc->title, 'HTMLDocument';

    my $notfound = $books->ensure(qw/not found/);
    is $notfound, undef;

    my $doc_child = $books->ensure(qw/Example@example 01-English@en 01-Formatters@formatters 01-HTMLDocument@htmldoc.html child/);
    is $doc_child, undef;
}

done_testing;
