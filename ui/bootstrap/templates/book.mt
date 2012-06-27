? extends 'node';

? block brand => sub {
    <?= raw($helper->link_to_node($ctx->book, class => 'brand')); ?>
? };

? block global_primary_nav => sub {
    <?= include('partial/header/quicksearch'); ?>
? };

? block content => sub {
?    my @children = $ctx->book->ctx_children($ctx);
?    for my $child ( @children ) {
    <?= include 'partial/node/digest', node => $child, sitemap => 1; ?>
?    }
? };
