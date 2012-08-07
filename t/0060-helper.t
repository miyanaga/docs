use strict;
use warnings;
use utf8;

use Test::More;
use Docs;
use Docs::UI::Helper;

my $app = Docs::app(books_path => 't/books');

{
    my $ctx = $app->new_context(lang => 'en');
    my $helper = Docs::UI::Helper->new(context => $ctx);

    my $node = $app->books->path_find('/example/en/formatters/mddoc');

    is $helper->link_to_node($node), '<a href="/example/en/formatters/mddoc"><span class="docs-numbering">1.1.2.</span> <span class="docs-node-title">MarkdownDocument</span></a>';
    is $helper->link_to_node($node, nonumbering => 1), '<a href="/example/en/formatters/mddoc">MarkdownDocument</a>';

    is $helper->node_action($node, 'search', { q => '検索キーワード' }, 'HASH' ),
        '/example/en/formatters/mddoc?action=search&q=%E6%A4%9C%E7%B4%A2%E3%82%AD%E3%83%BC%E3%83%AF%E3%83%BC%E3%83%89#HASH';
}

{
    my $node = $app->books->path_find('/example/tagged/simple');
    my $ctx = $app->new_context(lang => 'en', node => $node);
    my $tag = shift @{$node->ctx_tags($ctx)};

    my $helper = Docs::UI::Helper->new(context => $ctx);

    is $helper->link_to_tag($tag), '<a class="label" href="/example?action=search&amp;q=tag%3ATAG">TAG</a>';
}

{
    my $node = $app->books->path_find('/example/tagged/grouped');
    my $ctx = $app->new_context(lang => 'en', node => $node);
    my @tags = $node->ctx_tags($ctx);

    my $helper = Docs::UI::Helper->new(context => $ctx);

    is $helper->link_to_tag($tags[0]), '<a class="label label-info" href="/example?action=search&amp;q=tag%3AGROUP%3ATAG">TAG</a>';
    is $helper->link_to_tag($tags[1]), '<a class="label" href="/example?action=search&amp;q=tag%3ANOCLASS%3ATAG">TAG</a>';

    is $helper->link_to_tag($tags[1], nolink => 1), '<span class="label">TAG</span>';
}

{
    my $node = $app->books->path_find('/example/en/formatters/mddoc');
    ok $node;
    my $epoch = 1340329772; # 2012/6/22 01:49:32

    {
        my $ctx = $app->new_context(lang => 'en');
        my $helper = Docs::UI::Helper->new(context => $ctx);

        is $helper->format_datetime($node->ctx_datetime_format($ctx), $epoch), '2012/06/22 01:49:32';
        is $helper->format_datetime($node->ctx_date_format($ctx), $epoch), '2012/06/22';
    }

    {
        my $ctx = $app->new_context(lang => 'ja');
        my $helper = Docs::UI::Helper->new(context => $ctx);
        is $helper->format_datetime($node->ctx_datetime_format($ctx), $epoch), '2012年06月22日 01:49:32';
        is $helper->format_datetime($node->ctx_date_format($ctx), $epoch), '2012年06月22日';
    }

}

{
    my $node = $app->books->path_find('/example/en/index');
    my $ctx = $app->new_context(lang => 'en', node => $node);

    my $helper = Docs::UI::Helper->new(context => $ctx);

    is $helper->facebook_comment_load, q|
<div id="fb-root"></div>
<script>(function(d, s, id) {
  var js, fjs = d.getElementsByTagName(s)[0];
  if (d.getElementById(id)) return;
  js = d.createElement(s); js.id = id;
  js.src = "//connect.facebook.net/ja_JP/all.js#xfbml=1&appId=0123456789";
  fjs.parentNode.insertBefore(js, fjs);
}(document, 'script', 'facebook-jssdk'));</script>
<style>
    .facebook-comment { margin-top: 16px; }
    .fb_iframe_widget,.fb_iframe_widget * { max-width: 100% !important; }
    @media print { .facebook-comment { display: none !important } }
</style>
|;

    is $helper->facebook_comment_form, q|
<div class="facebook-comment">
<script>document.write('<div class="fb-comments" data-href="' + location.href + '" data-num-posts="2" data-width="9999"></div>');</script>
</div>
|;

    $node = $app->books->path_find('/example/ja');
    $ctx = $app->new_context(lang => 'en', node => $node);
    $helper = $ctx->new_helper;

    is $helper->facebook_comment_load, '';
    is $helper->facebook_comment_form, '';
}

{
    my $node = $app->books->path_find('/example/en');
    ok $node;

    my $ctx = $app->new_context(lang => 'en', node => $node);
    my $helper = $ctx->new_helper;

    is $helper->node_author_gravatar($node), q{<img class="docs-author-gravatar" src="http://www.gravatar.com/avatar/53ea23014763c68cf72d3d3e65dc0dd6?s=48&amp;d=404">};
}

done_testing;
