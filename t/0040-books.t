use strict;
use warnings;
use utf8;

use Test::More;
use Docs;
use Docs::Context;

my $app = Docs::app(books_path => 't/books');

my $books = $app->books;
my $ctx = Docs::Context->new;

{
    ok $books;
    is $books->uri_name, '';
    is $books->file_name, 't/books';
}

my $book = $books->find_uri('example');

{
    ok $book;
    is $book->file_name, 'Example@example';
    is $book->uri_name, 'example';
    is $book->naming->title, 'Example';

    my @children = values %{$book->children('uri')};
    is scalar @children, 7;
}

my $en = $book->find_uri('en');

{
    ok $en;
    is $en->file_name, '01-English@en';
    is $en->uri_name, 'en';
    is $en->order, 1;
    is $en->naming->title, 'English';

    my @children = values %{$en->children('uri')};
    is scalar @children, 7;
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
    my $html = $en->find_uri(qw/formatters htmldoc/);
    ok $html;
    is $html->file_name, '01-HTMLDocument@htmldoc.html';
    is $html->uri_name, 'htmldoc';
    is $html->order, 1;
    is $html->naming->title, 'HTMLDocument';
    is $html->naming->extension, 'html';

    my $ctx = $app->new_context(lang => 'en');
    is $html->ctx_plain_lead($ctx), '';
    is $html->ctx_body_without_lead($ctx), q{<h1>This Is A Raw HTML Document</h1>

<p>If the file extension is .html, then the file will parsed as raw HTML document.</p>
};
}

{
    my $md = $en->find_uri('formatters', 'mddoc');
    ok $md;
    is $md->file_name, '02-MarkdownDocument@mddoc.md';
    is $md->uri_name, 'mddoc';
    is $md->order, 2;
    is $md->naming->title, 'MarkdownDocument';
    is $md->naming->extension, 'md';

    my $ctx = $app->new_context(lang => 'en');
    is $md->ctx_plain_lead($ctx), '';
    is $md->ctx_body_without_lead($ctx), q{<h1>This Is A Markdown Document</h1>

<p>If the file extension is .md, then the file will be parsed as Markdown document.</p>
};
}

{
    my $folder = $en->find_uri(q/meta/);
    ok $folder;

    is $folder->metadata->find('title')->as_scalar, 'Metadata Testing';
    is $folder->metadata->find('title.ja')->as_scalar, 'メタデータテスト';
    is $folder->metadata->find('tags')->as_scalar, 'meta,folder,test';
    is $folder->metadata->cascade_find('author')->as_scalar, 'The Author';

    my $ctx = Docs::Context->new(lang => 'ja');
    is $folder->metadata->ctx_find($ctx, 'title')->as_scalar, 'メタデータテスト';
    is $folder->metadata->ctx_cascade_find($ctx, 'author')->as_scalar, '著者';
    is $folder->ctx_title($ctx), 'メタデータテスト';
    is $folder->ctx_author($ctx), '著者';

    $ctx = Docs::Context->new(lang => 'en');
    is $folder->metadata->ctx_find($ctx, 'title')->as_scalar, 'Metadata Testing';
    is $folder->metadata->ctx_cascade_find($ctx, 'author')->as_scalar, 'The Author';
    is $folder->ctx_title($ctx), 'Metadata Testing';
    is $folder->ctx_author($ctx), 'The Author';

    is $folder->ctx_lead($ctx), 'Lead of folder';
}

{
    my $doc = $en->find_uri(qw/meta docmeta/);
    ok $doc;

    is $doc->metadata->find('title')->as_scalar, 'Document Has Meta';
    is $doc->metadata->find('title.ja')->as_scalar, 'メタデータ付きドキュメント';
    is $doc->metadata->find('tags')->as_scalar, 'meta,document,test';
    is $doc->metadata->cascade_find('author')->as_scalar, 'The Author';
    is $doc->formatted_body, qq{<h1>Document Has Meta</h1>

<p>HTML comment at document head means document meta data.</p>
};

    my $ctx = Docs::Context->new(lang => 'ja');
    is $doc->metadata->ctx_find($ctx, 'title')->as_scalar, 'メタデータ付きドキュメント';
    is $doc->metadata->ctx_cascade_find($ctx, 'author')->as_scalar, '著者';
    is $doc->ctx_title($ctx), 'メタデータ付きドキュメント';
    is $doc->ctx_author($ctx), '著者';
    is $doc->ctx_lead($ctx), 'メタデータのリード文';

    $ctx = new Docs::Context->new(lang => 'en');
    is $doc->metadata->ctx_find($ctx, 'title')->as_scalar, 'Document Has Meta';
    is $doc->metadata->ctx_cascade_find($ctx, 'author')->as_scalar, 'The Author';
    is $doc->ctx_title($ctx), 'Document Has Meta';
    is $doc->ctx_author($ctx), 'The Author';
    is $doc->ctx_lead($ctx), 'Lead in meta';
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

    my $ctx = Docs::Context->new(lang => 'en');
    is $folder->ctx_title($ctx), 'Multi Language Folder';
    is $folder->ctx_author($ctx), 'Folder Author';

    $tags = $folder->ctx_raw_tags($ctx);
    is_deeply $tags, [qw/Folder:Tag0 Folder:Tag1/];
    $tags = $folder->ctx_tags($ctx);
    is $tags->[0]->group, 'Folder';
    is $tags->[0]->label, 'Tag0';


    is $doc->ctx_title($ctx), 'Multi Language Document';
    is $doc->ctx_author($ctx), 'Document Author';
    is $doc->ctx_body($ctx), qq(<h1>Headline</h1>

<p>Content</p>
);
    $tags = $doc->ctx_raw_tags($ctx);
    is_deeply $tags, [qw/Document:Tag0 Document:Tag1/];
    $tags = $doc->ctx_tags($ctx);
    is $tags->[0]->group, 'Document';
    is $tags->[0]->label, 'Tag0';


    $ctx = new Docs::Context->new(lang => 'ja');
    is $folder->ctx_title($ctx), '多言語フォルダ';
    is $folder->ctx_author($ctx), 'フォルダの著者';
    $tags = $folder->ctx_raw_tags($ctx);
    is_deeply $tags, [qw/フォルダ:Tag0 フォルダ:Tag1/];
    $tags = $folder->ctx_tags($ctx);
    is $tags->[0]->group, 'フォルダ';
    is $tags->[0]->label, 'Tag0';

    is $doc->ctx_title($ctx), '多言語ドキュメント';
    is $doc->ctx_author($ctx), 'ドキュメントの著者';
    is $doc->ctx_body($ctx), qq(<h1>見出し</h1>

<p>内容</p>
);
    $tags = $doc->ctx_raw_tags($ctx);
    is_deeply $tags, [qw/ドキュメント:Tag0 ドキュメント:Tag1/];
    $tags = $doc->ctx_tags($ctx);
    is $tags->[0]->group, 'ドキュメント';
    is $tags->[0]->label, 'Tag0';
}

{
    my $node = $books->path_find('/example/en/formatters/mddoc');
    is $node->ctx_author($ctx), 'Kunihiko Miyanaga <miyanaga@ideamans.com>';
    is $node->ctx_author_name($ctx), 'Kunihiko Miyanaga';
    is $node->ctx_author_email($ctx), 'miyanaga@ideamans.com';
}

{
    my $node = $books->path_find('/example/seealso/doc');
    ok $node;

    my @seealso = $node->ctx_seealso($ctx);
    is scalar @seealso, 2;
    is $seealso[0]->uri_name, 'htmldoc';
    is $seealso[1]->uri_name, 'first';
}

{
    my $third = $books->path_find('/example/en/sibling/third');
    ok $third;
    my $ctx = $app->new_context(lang => 'en');

    is $third->ctx_next($ctx)->uri_name, 'fourth';
    is $third->ctx_next($ctx)->ctx_next($ctx), undef;
    is $third->ctx_prev($ctx)->uri_name, 'first';
    is $third->ctx_prev($ctx)->ctx_prev($ctx), undef;

    my $fourth = $books->path_find('/example/en/sibling/fourth');

}

{
    my $third = $books->path_find('/example/en/sibling/third');
    ok $third;
    my $ctx = $app->new_context(lang => 'en');

    is $third->ctx_number($ctx), '2.';
    is $third->ctx_numbering($ctx), '1.5.2.';
}

{
    my $third = $books->path_find('/example/en/sibling/third');
    ok $third;
    is $third->folder->uri_name, 'sibling';
    is $third->folder->folder->uri_name, 'sibling';

    my $sibling = $third->path_find('.');
    is $sibling->uri_name, 'sibling';

    $sibling = $third->path_find('../sibling');
    is $sibling->uri_name, 'sibling';

    my $en = $third->path_find('..');
    is $en->uri_name, 'en';

    $en = $sibling->path_find('..');
    is $en->uri_name, 'en';

    my $example = $third->path_find('../..');
    is $example->uri_name, 'example';
}

{
    my $visibility = $books->path_find('/example/en/visibility');
    ok $visibility;

    my $first = $visibility->find_uri('first');
    my $second = $visibility->find_uri('second');
    my $third = $visibility->find_uri('third');
    my $fourth = $visibility->find_uri('fourth');
    my $fifth = $visibility->find_uri('fifth');

    {
        my $ctx = $app->new_context(lang => 'en');
        is $first->ctx_hidden($ctx), 0;
        is $second->ctx_hidden($ctx), 1;
        is $third->ctx_hidden($ctx), 0;
        is $fourth->ctx_hidden($ctx), 1;
        is $fifth->ctx_hidden($ctx), 1;

        my @children = map { $_->uri_name } @{$visibility->ctx_children($ctx)};
        is_deeply \@children, [qw/first third/];
    }

    {
        my $ctx = $app->new_context(lang => 'ja');
        is $first->ctx_hidden($ctx), 1;
        is $second->ctx_hidden($ctx), 0;
        is $third->ctx_hidden($ctx), 1;
        is $fourth->ctx_hidden($ctx), 0;
        is $fifth->ctx_hidden($ctx), 1;

        my @children = map { $_->uri_name } @{$visibility->ctx_children($ctx)};
        is_deeply \@children, [qw/second fourth/];
    }
}

{
    my $book = $books->find_uri(qw/example/);
    ok $book;
    my $md = $book->find_uri(qw/en formatters mddoc/);
    ok $md;

    my $ctx;
    my $glossary;

    $ctx = $app->new_context(lang => 'en');
    $glossary = $book->ctx_glossary($ctx);

    is_deeply $glossary, {
        extension => {
            keyword => 'extension',
            description => 'The last part of filename describes file type.',
            link => '',
        },
        html => {
            keyword => 'HTML',
            description => 'Hyper Text Markup Language',
            link => '',
        },
    };

    $glossary = $md->ctx_glossary($ctx);

    is_deeply $glossary, {
        extension => {
            keyword => 'extension',
            description => 'The last part of filename describes file type.',
            link => '',
        },
        html => {
            keyword => 'HTML',
            description => 'Hyper Text Markup Language',
            link => '',
        },
        markdown => {
            keyword => 'Markdown',
            description => 'One of text writing style like Wiki, and compatible with HTML.',
            link => '',
        },
    };

    $ctx = $app->new_context(lang => 'ja');
    $glossary = $book->ctx_glossary($ctx);

    is_deeply $glossary, {
        '拡張子' => {
            keyword => '拡張子',
            description => 'ファイル名の最後の部分でファイルのタイプを示します。',
            link => '',
        },
        html => {
            keyword => 'HTML',
            description => 'ハイパーテキストマークアップ言語',
            link => '',
        },
    };

    $glossary = $md->ctx_glossary($ctx);

    is_deeply $glossary, {
        '拡張子' => {
            keyword => '拡張子',
            description => 'ファイル名の最後の部分でファイルのタイプを示します。',
            link => '',
        },
        html => {
            keyword => 'HTML',
            description => 'ハイパーテキストマークアップ言語',
            link => '',
        },
        markdown => {
            keyword => 'Markdown',
            description => 'Wikiに似たテキスト記法のひとつで、HTMLとの互換性があります。',
            link => '',
        },
    };
}

{
    my $docstags = $book->find_uri(qw/docstags folder index/);
    ok $docstags;

    my $ctx = $app->new_context(lang => 'en');
    my $html = $docstags->ctx_html($ctx);

    is $html, <<'HTML';
<p><a href="/example/en"><span class="docs-numbering">1.</span> <span class="docs-node-title">English</span></a>
<a href="/example/en"><span class="docs-numbering">1.</span> <span class="docs-node-title">English</span></a>
<a href="/example/docstags"><span class="docs-numbering">6.</span> <span class="docs-node-title">DocsTags</span></a>
<a href="/example/docstags/folder"><span class="docs-numbering">6.1.</span> <span class="docs-node-title">Folder</span></a>
<a href="/example/en"><span class="docs-numbering">1.</span> <span class="docs-node-title">English</span></a>
<a href="/example/en"><span class="docs-numbering">1.</span> <span class="docs-node-title">English</span></a>
<a href="/example/en/formatters/mddoc"><span class="docs-numbering">1.1.2.</span> <span class="docs-node-title">MarkdownDocument</span></a>
<a href="/example/en/formatters/htmldoc#anchor"><span class="docs-numbering">1.1.1.</span> <span class="docs-node-title">HTMLDocument</span></a>
<a href="/example/docstags/folder"><span class="docs-numbering">6.1.</span> <span class="docs-node-title">Folder</span></a>
<a class="label" href="/example?action=search&amp;q=tag%3ABODY%3ATAG1">TAG1</a>
<a class="label" href="/example?action=search&amp;q=tag%3ABODY%3ATAG2">TAG2</a></p>
HTML
}

{
    my $docstags = $book->find_uri(qw/docstags folder index/);
    ok $docstags;

    my $ctx = $app->new_context(lang => 'en');
    my @tags = sort { $a cmp $b } map { $_->raw } @{$docstags->ctx_tags_include_body($ctx)};

    is_deeply \@tags, [qw/BODY:TAG1 BODY:TAG2 META:TAG1 META:TAG2/];
}

{
    my $docspre = $book->find_uri(qw/docstags pre/);
    ok $docspre;

    my $ctx = $app->new_context(lang => 'en');
    is $docspre->ctx_html($ctx), q{<pre class="lang">
    &lt;!--
        id: pre
        test: &amp;abc
    --&gt;
</pre>

<pre>
    &lt;html&gt;&lt;/html&gt;
</pre>
};
}

{
    my $en = $book->find_uri(qw/en index/);
    ok $en;

    my $ctx = $app->new_context(lang => 'en');
    is $en->ctx_first_paragraph($ctx), q{This is English document.<br />
The quick brown fox jumps over the lazy dog<br />
The quick brown fox jumps over the lazy dog<br />
The quick brown fox jumps over the lazy dog<br />
The quick brown fox jumps over the lazy dog<br />
The quick brown fox jumps over the lazy dog<br />};
    is $en->ctx_excerpt($ctx), q{This is English document. The quick brown fox jumps over the lazy dog The quick brown fox jumps over the lazy dog The quick brown fox jumps over the lazy dog The quick brown fox jumps over the lazy dog The...};
}

{
    my $mddoc = $book->find_uri(qw/en formatters mddoc/);
    ok $mddoc;

    my $ctx = $app->new_context(lang => 'en');
    my $excerpt = $mddoc->ctx_excerpt($ctx);
    is $excerpt, q{Lead in md};
}

{
    my $ja = $book->find_uri(qw/ja jadoc/);
    my $ctx = $app->new_context(lang => 'ja');
    is $ja->ctx_first_paragraph($ctx), q{日本語を含むドキュメントのテストです。<br />
いろはにほへと ちりぬるを わかよたれそ つねならむ うゐのおくやま けふこえて あさきゆめみし ゑひもせすん<br />
いろはにほへと ちりぬるを わかよたれそ つねならむ うゐのおくやま けふこえて あさきゆめみし ゑひもせすん<br />
いろはにほへと ちりぬるを わかよたれそ つねならむ うゐのおくやま けふこえて あさきゆめみし ゑひもせすん<br />
いろはにほへと ちりぬるを わかよたれそ つねならむ うゐのおくやま けふこえて あさきゆめみし ゑひもせすん<br />
いろはにほへと ちりぬるを わかよたれそ つねならむ うゐのおくやま けふこえて あさきゆめみし ゑひもせすん<br />};
    is $ja->ctx_excerpt($ctx), q{日本語を含むドキュメントのテストです。 いろはにほへと ちりぬるを わかよたれそ つねならむ うゐのおくやま けふこえて あさきゆめみし ゑひもせすん いろはにほへと ちりぬるを わかよたれそ つねならむ うゐのおくやま けふこえて あさきゆめみし ゑひもせすん いろはにほへと ちりぬるを わかよたれそ つねならむ うゐのおくやま けふこえて あさきゆめみし ゑひもせすん いろはにほへと ちりぬる...};
}

{
    my $node = $app->books->path_find('/example/en');
    ok $node;

    my $ctx = $app->new_context(lang => 'en', node => $node);
    is $node->ctx_author_gravatar($ctx), q{http://www.gravatar.com/avatar/53ea23014763c68cf72d3d3e65dc0dd6?s=48&d=404};
}

done_testing;
