<?
extends 'layout/two-columns';
my %args = @_;
my $html = $args{html};
my $document = $ctx->document;
my $folder = $ctx->folder;
my $node = $ctx->node;
my $global_nav_limit = int( $ctx->app->config->cascade_find(qw/ui bootstrap global_nav_limit/)->as_scalar // 10 );
my $shortcut_level = $node->metadata->ctx_cascade_find($ctx, 'headline_shortcut', 'level')->as_scalar // 1;
my $shortcut_levels = $shortcut_level =~ /^[0-9]+$/
    ? join(',', map { "h$_" } ( 1..int($shortcut_level) ) )
    : $shortcut_level;
my $caption = $node->metadata->ctx_cascade_find($ctx, 'caption')->as_scalar || 'never';
?>

? block global_primary_nav => sub {
    <? my @menus = $ctx->book->ctx_children($ctx); ?>
    <? my @opened = grep { $_ } map { shift @menus } (1..$global_nav_limit) ?>
    <? for my $node ( @opened ) { ?>
        <li class="<?= $ctx->has_node_in_path($node)? 'active': ''; ?>"><?= raw($helper->link_to_node($node, nonumbering => 1)) ?></li>
    <? } ?>

    <? if ( @menus ) { ?>
    <li class="dropdown docs-nav-more">
        <a href="#" class="dropdown-toggle">
            <?= raw($helper->theme_icon('chevron-right', 1)) ?>
        </a>
        <ul class="dropdown-menu">
            <? for my $node ( @menus ) { ?>
                <li class="<?= $ctx->has_node_in_path($node)? 'active': ''; ?>"><?= raw($helper->link_to_node($node, nonumbering => 1)) ?></li>
            <? } ?>
        </ul>
    </li>
    <? } ?>

    <?= include('partial/header/quicksearch'); ?>
    <?= include('partial/header/books'); ?>
? };

? block global_header => sub {
<ul class="nav pull-right">
    <?= include('partial/header/languages'); ?>
</ul>
? };

? block sidebar => sub {
    <?= include 'navigation/node'; ?>
? };

? block html_head => sub {
? };

? block content => sub {
    <? if ( $ctx->node->parent ) { ?>
    <ul class="docs-breadcrumb nav print">
        <? for my $parent ( grep { $_->depth > 0 } reverse $ctx->node->parents ) { ?>
            <li>
                <?= raw($helper->link_to_node($parent, nolink => 1)) ?>
            </li>
        <? } ?>
    </ul>
    <? } ?>

    <article class="docs-node" data-node-url="<?= $document->uri_path ?>">
        <header class="docs-node-header">
            <?= include 'partial/node/section_header', node => $document ?>
            <hr>
        </header>

        <? if ( $html ) { ?>
        <section class="docs-node-body" data-headline-shortcut-levels="<?= $shortcut_levels ?>" data-caption="<?= $caption ?>">
            <ul class="well docs-headline-shortcuts pull-right nav nav-stacked nav-pills"></ul>
            <?= raw($html); ?>
        </section>
        <? } ?>

        <? if ( $document->is_folder || $document->is_index ) { ?>
            <section class="node-children">
                <? if ( my @children = $folder->ctx_children($ctx) ) { ?>
                    <? for my $child ( @children ) { ?>
                        <?= include 'partial/node/digest', node => $child, sitemap => 1; ?>
                    <? } ?>
                <? } ?>
            </section>
        <? } ?>

        <footer class="docs-node-footer">
            <hr>
            <div class="docs-node-footnote"></div>
            <div class="docs-node-relations" data-node="<?= $document->uri_path ?>"></div>

            <?= include 'partial/node/section_footer', node => $document ?>
            <?= raw($helper->facebook_comment_form) if $helper->can('facebook_comment_form') ?>
        </footer>
    </artible>

? }
