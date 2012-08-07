? extends 'layout/one-column';
? my $document = $ctx->books;

? block content => sub {
?    if ( my $lead = $ctx->books->ctx_lead($ctx) ) {
<p><?= raw($lead); ?></p>
?    }

    <article class="docs-node" data-node-url="<?= $document->uri_path ?>">
        <? if ( my $body = $document->ctx_html($ctx) ) { ?>
        <section class="docs-node-body">
            <ul class="well docs-headline-shortcuts pull-right nav nav-stacked nav-pills"></ul>
            <?= raw($body); ?>
        </section>
        <? } ?>
    </artible>

<? for my $book ( $ctx->books->ctx_children($ctx) ) { ?>
    <?= include 'partial/node/digest', node => $book, sitemap => 1 ?>
<? } ?>
? }
