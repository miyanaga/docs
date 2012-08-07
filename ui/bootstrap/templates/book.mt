? extends 'node';

? block brand => sub {
    <?= raw($helper->link_to_node($ctx->book, class => 'brand')); ?>
? };

? block global_primary_nav => sub {
    <?= include('partial/header/quicksearch'); ?>
? };
