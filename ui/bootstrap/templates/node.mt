? extends 'layout/two-columns';
? my $document = $ctx->document;
? my $folder = $ctx->folder;
? my $node = $ctx->node;
? my $global_nav_limit = Docs::app()->config->cascade_find(qw/ui bootstrap global_nav_limit/)->as_scalar;
? $global_nav_limit = 5 unless defined $global_nav_limit;

? block brand => sub {
    <?= raw($helper->link_to_node($ctx->book, class => 'brand')); ?>
? };

? block global_primary_nav => sub {
    <? my @menus = $ctx->book->ctx_children($ctx); ?>
    <? my @opened = grep { $_ } map { shift @menus } (1..$global_nav_limit) ?>
    <? for my $node ( @opened ) { ?>
        <li class="<?= $ctx->has_node_in_path($node)? 'active': ''; ?>"><?= raw($helper->link_to_node($node, nonumbering => 1)) ?></li>
    <? } ?>

    <? if ( @menus ) { ?>
    <li class="dropdown">
        <a href="#" class="dropdown-toggle">
            <?= raw($helper->theme_icon('chevron-down', 1)) ?>
        </a>
        <ul class="dropdown-menu">
            <? for my $node ( @menus ) { ?>
                <li class="<?= $ctx->has_node_in_path($node)? 'active': ''; ?>"><?= raw($helper->link_to_node($node, nonumbering => 1)) ?></li>
            <? } ?>
        </ul>
    </li>
    <? } ?>

    <?= include('partial/header/quicksearch'); ?>
? };

? block global_secondary_nav => sub {
    <?= include('partial/header/books'); ?>
? }

? block global_header => sub {
<ul class="nav pull-right">
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
    <article id="docs-node" data-node-url="<?= $document->uri_path ?>">
        <header id="docs-node-header">
            <?= include 'partial/node/section_header', node => $document ?>
            <hr>
        </header>

        <? if ( my $body = $document->ctx_body($ctx) ) { ?>
        <section id="docs-node-body">
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

        <footer id="docs-node-footer">
            <hr>
            <div id="docs-node-footnote"></div>
            <div id="docs-node-relations" data-node="<?= $document->uri_path ?>"></div>

            <?= include 'partial/node/section_footer', node => $document ?>
        </footer>
    </artible>

? }
