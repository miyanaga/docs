? extends 'layout/two-columns';
? my $document = $ctx->document;
? my $folder = $ctx->folder;
? my $node = $ctx->node;

? block brand => sub {
    <?= raw($helper->link_to_node($ctx->book, class => 'brand')); ?>
? };

? block global_primary_nav => sub {
    <? for my $node ( @{$ctx->book->ctx_children($ctx)} ) { ?>
        <li class="<?= $ctx->has_node_in_path($node)? 'active': ''; ?>"><?= raw($helper->link_to_node($node, nonumbering => 1)) ?></li>
    <? } ?>
    <?= include('partial/header/quicksearch'); ?>
? };

? block global_header => sub {
<ul class="nav pull-right">
    <?= include('partial/header/books'); ?>
    <?= include('partial/header/languages'); ?>
</ul>
? };

? block sidebar => sub {
    <?= include 'navigation/node'; ?>
? };

? block html_head => sub {
    <? if ($folder) { ?>
    <base href="<?= $folder->ctx_base_href($ctx) ?>/">
    <? } ?>
? };

? block content => sub {
    <article id="node">
        <header id="node-header">
            <?= include 'partial/node/section_header', node => $document ?>
            <hr>
        </header>

        <? if ( my $body = $document->ctx_body($ctx) ) { ?>
        <section id="node-body">
                <?= raw($body); ?>
        </section>
        <? } ?>

        <? if ( $document->is_folder || $document->is_index ) { ?>
            <section id="node-children">
                <? if ( my @children = $folder->ctx_children($ctx) ) { ?>
                    <? for my $child ( @children ) { ?>
                        <?= include 'partial/node/digest', node => $child, sitemap => 1; ?>
                    <? } ?>
                <? } ?>
            </section>
        <? } ?>

        <footer id="node-footer">
            <hr>
            <div id="node-relations" data-node="<?= $document->uri_path ?>"></div>

            <?= include 'partial/node/section_footer', node => $document ?>
        </footer>
    </artible>

? }
