use strict;
use warnings;

use Test::More;
use Docs;
use Docs::Context;

my $app = Docs::app;

my $books = $app->books;
my $ctx = Docs::Context->new;

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
    is $book->naming->title, 'Example';

    my @children = values %{$book->children('uri')};
    is scalar @children, 2;
}

my $en = $book->find_uri('en');

{
    ok $en;
    is $en->file_name, '01-English@en';
    is $en->uri_name, 'en';
    is $en->order, 1;
    is $en->naming->title, 'English';

    my @children = values %{$en->children('uri')};
    is scalar @children, 4;
}

my $ja = $book->find_uri('ja');

{
    ok $ja;
    is $ja->file_name, '02-日本語@ja';
    is $ja->uri_name, 'ja';
    is $ja->order, 2;
    is $ja->naming->title, '日本語';
}

{
    my $md = $en->find_uri('formatters', 'mddoc');
    ok $md;
    is $md->file_name, '02-MarkdownDocument@mddoc.md';
    is $md->uri_name, 'mddoc';
    is $md->order, 2;
    is $md->naming->title, 'MarkdownDocument';
    is $md->naming->extension, 'md';
}

{
    my $folder = $en->find_uri(q/meta/);
    ok $folder;

    is $folder->metadata->title->_scalar, 'Metadata Testing';
    is $folder->metadata->_find('title.ja')->_scalar, 'メタデータテスト';
    is $folder->metadata->_find('tags')->_scalar, 'meta,folder,test';
    is $folder->metadata->_cascade_find('author')->_scalar, 'The Author';

    my $ctx = Docs::Context->new(language => 'ja');
    is $folder->metadata->_ctx_find($ctx, 'title')->_scalar, 'メタデータテスト';
    is $folder->metadata->_ctx_cascade_find($ctx, 'author')->_scalar, '著者';
    is $folder->title($ctx), 'メタデータテスト';
    is $folder->author($ctx), '著者';

    $ctx->language('en');
    is $folder->metadata->_ctx_find($ctx, 'title')->_scalar, 'Metadata Testing';
    is $folder->metadata->_ctx_cascade_find($ctx, 'author')->_scalar, 'The Author';
    is $folder->title($ctx), 'Metadata Testing';
    is $folder->author($ctx), 'The Author';
}

{
    my $doc = $en->find_uri(qw/meta docmeta/);
    ok $doc;

    is $doc->metadata->title->_scalar, 'Document Has Meta';
    is $doc->metadata->_find('title.ja')->_scalar, 'メタデータ付きドキュメント';
    is $doc->metadata->_find('tags')->_scalar, 'meta,document,test';
    is $doc->metadata->_cascade_find('author')->_scalar, 'The Author';
    is $doc->formatted_body, qq{<h1>Document Has Meta</h1>

<p>HTML comment at document head means document meta data.</p>
};

    my $ctx = Docs::Context->new(language => 'ja');
    is $doc->metadata->_ctx_find($ctx, 'title')->_scalar, 'メタデータ付きドキュメント';
    is $doc->metadata->_ctx_cascade_find($ctx, 'author')->_scalar, '著者';
    is $doc->title($ctx), 'メタデータ付きドキュメント';
    is $doc->author($ctx), '著者';

    $ctx->language('en');
    is $doc->metadata->_ctx_find($ctx, 'title')->_scalar, 'Document Has Meta';
    is $doc->metadata->_ctx_cascade_find($ctx, 'author')->_scalar, 'The Author';
    is $doc->title($ctx), 'Document Has Meta';
    is $doc->author($ctx), 'The Author';
}

{
    my $undef = $en->find_uri(qw/not found/);
    is $undef, undef;
}

{
    my $folder = $books->ensure(qw/Example@example 01-English@en 01-Formatters@formatters/);
    ok $folder;
    is $folder->naming->title, 'Formatters';

    my $doc = $books->ensure(qw/Example@example 01-English@en 01-Formatters@formatters 01-HTMLDocument@htmldoc.html/);
    ok $doc;
    is $doc->naming->title, 'HTMLDocument';

    my $notfound = $books->ensure(qw/not found/);
    is $notfound, undef;

    my $doc_child = $books->ensure(qw/Example@example 01-English@en 01-Formatters@formatters 01-HTMLDocument@htmldoc.html child/);
    is $doc_child, undef;
}

{
    my $folder = $books->find_uri(qw/example en multilang/);
    ok $folder;

    my $doc = $folder->find_uri(qw/document/);
    ok $doc;

    my $tags;

    my $ctx = Docs::Context->new(language => 'en');
    is $folder->title($ctx), 'Multi Language Folder';
    is $folder->author($ctx), 'Folder Author';

    $tags = $folder->raw_tags($ctx);
    is_deeply $tags, [qw/Folder:Tag0 Folder:Tag1/];
    $tags = $folder->tags($ctx);
    is $tags->[0]->group, 'Folder';
    is $tags->[0]->label, 'Tag0';


    is $doc->title($ctx), 'Multi Language Document';
    is $doc->author($ctx), 'Document Author';
    is $doc->body($ctx), qq(<h1>Headline</h1>

<p>Content</p>
);
    $tags = $doc->raw_tags($ctx);
    is_deeply $tags, [qw/Document:Tag0 Document:Tag1/];
    $tags = $doc->tags($ctx);
    is $tags->[0]->group, 'Document';
    is $tags->[0]->label, 'Tag0';


    $ctx->language('ja');
    is $folder->title($ctx), '多言語フォルダ';
    is $folder->author($ctx), 'フォルダの著者';
    $tags = $folder->raw_tags($ctx);
    is_deeply $tags, [qw/フォルダ:Tag0 フォルダ:Tag1/];
    $tags = $folder->tags($ctx);
    is $tags->[0]->group, 'フォルダ';
    is $tags->[0]->label, 'Tag0';

    is $doc->title($ctx), '多言語ドキュメント';
    is $doc->author($ctx), 'ドキュメントの著者';
    is $doc->body($ctx), qq(<h1>見出し</h1>

<p>内容</p>
);
    $tags = $doc->raw_tags($ctx);
    is_deeply $tags, [qw/ドキュメント:Tag0 ドキュメント:Tag1/];
    $tags = $doc->tags($ctx);
    is $tags->[0]->group, 'ドキュメント';
    is $tags->[0]->label, 'Tag0';
}

done_testing;
