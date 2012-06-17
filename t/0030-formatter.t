use strict;
use warnings;

use Test::More;
use Docs;

my $app = Docs::app;

{
    my $default = $app->formatter('html');
    ok $default;

    my $source = qq(<!--
tags: TAGS
-->
<h1>Example</h1>);

    is $default->format($source), '<h1>Example</h1>';

    my $meta = $default->metadata($source);
    is $meta->tags->_scalar, 'TAGS';
}

{
    my $md = $app->formatter('md');
    ok $md;
    my $source = qq(<!--
tags: TAGS
-->
# Example);

    is $md->format($source), '<h1>Example</h1>
';

    my $meta = $md->metadata($source);
    is $meta->tags->_scalar, 'TAGS';
}

{
    my $md = $app->formatter('md');

    my $source = qq(<!--
    bad: yaml
bad: yaml
-->);
    my $meta = $md->metadata($source);
    is $meta->tags->_scalar, undef;
}

done_testing;
