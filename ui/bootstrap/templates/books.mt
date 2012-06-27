? extends 'layout/one-column';

? block brand => sub {
    <?= raw($helper->link_to_node($ctx->books, class => 'brand')); ?>
? }

? block content => sub {
?    if ( my $lead = $ctx->books->ctx_lead($ctx) ) {
<p><?= raw($lead); ?></p>
?    }

<? for my $book ( $ctx->books->ctx_children($ctx) ) { ?>
    <?= include 'partial/node/digest', node => $book, sitemap => 1 ?>
<? } ?>
? }
